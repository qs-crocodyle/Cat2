-- Cat2 配置文本编码器。
-- 导出流程：紧凑二进制序列化 -> LZ 滑动窗口压缩 -> URL 安全 Base64。
-- 不写入函数、技能名称和描述；导入端后续只需按卡片 ID 从注册中心恢复运行时信息。
Cat2 = Cat2 or {}

local exportPrefix = "CAT2:3:"
local legacyExportPrefix = "CAT2:2:"
local base64Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
local base64Lookup = nil

local function Remainder(value, divisor)
    return value - math.floor(value / divisor) * divisor
end

local function PackUnsigned16(value)
    if value < 0 or value > 65535 then
        return nil
    end
    local high = math.floor(value / 256)
    local low = value - high * 256
    return string.char(high, low)
end

local function PackUnsigned32(value)
    local byte1 = math.floor(value / 16777216)
    value = value - byte1 * 16777216
    local byte2 = math.floor(value / 65536)
    value = value - byte2 * 65536
    local byte3 = math.floor(value / 256)
    local byte4 = value - byte3 * 256
    return string.char(byte1, byte2, byte3, byte4)
end

-- Adler-32 用于后续导入时识别复制不完整或文本被修改的情况。
local function CalculateChecksum(data)
    local first = 1
    local second = 0
    local index = 1
    local total = string.len(data)
    while index <= total do
        first = Remainder(first + string.byte(data, index), 65521)
        second = Remainder(second + first, 65521)
        index = index + 1
    end
    return second * 65536 + first
end

-- 只保存跨客户端恢复流程所需的最小字段。
local function SerializeProfile(profile, classFile)
    if type(profile) ~= "table" or type(profile.name) ~= "string" or type(profile.steps) ~= "table" then
        return nil, "配置数据无效"
    end
    if type(classFile) ~= "string" or classFile == "" then
        return nil, "无法识别当前角色职业"
    end

    local validSteps = {}
    local sourceIndex = 1
    local sourceTotal = table.getn(profile.steps)
    while sourceIndex <= sourceTotal do
        local step = profile.steps[sourceIndex]
        if step and type(step.id) == "string" then
            table.insert(validSteps, step)
        end
        sourceIndex = sourceIndex + 1
    end

    local profileNameLength = string.len(profile.name)
    local packedProfileNameLength = PackUnsigned16(profileNameLength)
    local classLength = string.len(classFile)
    local packedClassLength = PackUnsigned16(classLength)
    local stepTotal = table.getn(validSteps)
    if not packedProfileNameLength or not packedClassLength or stepTotal > 60 then
        return nil, "配置内容超出导出限制"
    end

    local iconLimit = 1
    local direction = "vertical"
    if profile.id and Cat2.GetProfileShortcutWindowSettings then
        local _, savedIconLimit, savedDirection = Cat2.GetProfileShortcutWindowSettings(profile.id)
        iconLimit = math.floor(tonumber(savedIconLimit) or 1)
        direction = savedDirection == "vertical" and "vertical" or "horizontal"
    end
    if iconLimit < 1 then
        iconLimit = 1
    end
    if iconLimit > 10 then
        iconLimit = 10
    end
    local directionFlag = direction == "vertical" and 1 or 0

    local output = {
        "C2",
        string.char(3),
        packedClassLength,
        classFile,
        packedProfileNameLength,
        profile.name,
        string.char(directionFlag),
        string.char(iconLimit),
        string.char(stepTotal)
    }
    local stepIndex = 1
    while stepIndex <= stepTotal do
        local step = validSteps[stepIndex]
        local idLength = string.len(step.id)
        local packedIdLength = PackUnsigned16(idLength)
        if not packedIdLength then
            return nil, "卡片 ID 超出导出限制"
        end
        local flags = 0
        if step.enabled ~= 0 then
            flags = flags + 1
        end
        if step.minimizedVisible ~= 0 then
            flags = flags + 2
        end
        table.insert(output, packedIdLength)
        table.insert(output, step.id)
        table.insert(output, string.char(flags))
        stepIndex = stepIndex + 1
    end
    return table.concat(output)
end

-- 在前 255 字节中寻找最长重复片段；三字节以上才值得写成匹配标记。
local function FindBestMatch(data, position, total)
    local maximumOffset = position - 1
    if maximumOffset > 255 then
        maximumOffset = 255
    end
    local bestLength = 0
    local bestOffset = 0
    local offset = 1
    while offset <= maximumOffset do
        local length = 0
        while length < 130 and position + length <= total do
            local sourceByte = string.byte(data, position - offset + length)
            local currentByte = string.byte(data, position + length)
            if sourceByte ~= currentByte then
                break
            end
            length = length + 1
        end
        if length > bestLength and length >= 3 then
            bestLength = length
            bestOffset = offset
            if bestLength >= 130 then
                break
            end
        end
        offset = offset + 1
    end
    return bestLength, bestOffset
end

-- PackBits 风格的文字段与 LZ 匹配段组合，适合压缩重复的卡片 ID 前缀。
local function CompressBinary(data)
    local output = {}
    local total = string.len(data)
    local position = 1
    local literalStart = 1
    local literalLength = 0

    local function FlushLiteral()
        if literalLength <= 0 then
            return
        end
        table.insert(output, string.char(literalLength - 1))
        table.insert(output, string.sub(data, literalStart, literalStart + literalLength - 1))
        literalLength = 0
    end

    while position <= total do
        local matchLength, matchOffset = FindBestMatch(data, position, total)
        if matchLength >= 3 then
            FlushLiteral()
            table.insert(output, string.char(128 + matchLength - 3))
            table.insert(output, string.char(matchOffset))
            position = position + matchLength
            literalStart = position
        else
            if literalLength == 0 then
                literalStart = position
            end
            literalLength = literalLength + 1
            position = position + 1
            if literalLength >= 128 then
                FlushLiteral()
                literalStart = position
            end
        end
    end
    FlushLiteral()
    return table.concat(output)
end

local function EncodeBase64(data)
    local output = {}
    local position = 1
    local total = string.len(data)
    while position <= total do
        local byte1 = string.byte(data, position) or 0
        local hasSecond = position + 1 <= total
        local hasThird = position + 2 <= total
        local byte2 = hasSecond and string.byte(data, position + 1) or 0
        local byte3 = hasThird and string.byte(data, position + 2) or 0

        local index1 = math.floor(byte1 / 4)
        local index2 = (byte1 - index1 * 4) * 16 + math.floor(byte2 / 16)
        local byte2High = math.floor(byte2 / 16)
        local index3 = (byte2 - byte2High * 16) * 4 + math.floor(byte3 / 64)
        local byte3High = math.floor(byte3 / 64)
        local index4 = byte3 - byte3High * 64

        table.insert(output, string.sub(base64Alphabet, index1 + 1, index1 + 1))
        table.insert(output, string.sub(base64Alphabet, index2 + 1, index2 + 1))
        if hasSecond then
            table.insert(output, string.sub(base64Alphabet, index3 + 1, index3 + 1))
        else
            table.insert(output, "=")
        end
        if hasThird then
            table.insert(output, string.sub(base64Alphabet, index4 + 1, index4 + 1))
        else
            table.insert(output, "=")
        end
        position = position + 3
    end
    return table.concat(output)
end

function Cat2.ExportConfigurationText(profile, classFile)
    local serialized, errorMessage = SerializeProfile(profile, classFile)
    if not serialized then
        return nil, errorMessage
    end
    local compressed = CompressBinary(serialized)
    local envelope = PackUnsigned32(CalculateChecksum(serialized)) .. compressed
    return exportPrefix .. EncodeBase64(envelope)
end

local function UnpackUnsigned16(data, position)
    -- 旧客户端的 string.byte 不支持通过结束位置一次返回多个字节。
    local high = string.byte(data, position)
    local low = string.byte(data, position + 1)
    if not high or not low then
        return nil
    end
    return high * 256 + low
end

local function UnpackUnsigned32(data, position)
    local byte1 = string.byte(data, position)
    local byte2 = string.byte(data, position + 1)
    local byte3 = string.byte(data, position + 2)
    local byte4 = string.byte(data, position + 3)
    if not byte1 or not byte2 or not byte3 or not byte4 then
        return nil
    end
    return byte1 * 16777216 + byte2 * 65536 + byte3 * 256 + byte4
end

-- 复制时允许混入换行、空格和制表符，其余字符必须属于导出字母表。
local function RemoveCopyWhitespace(text)
    local output = {}
    local index = 1
    local total = string.len(text)
    while index <= total do
        local character = string.sub(text, index, index)
        if character ~= " " and character ~= "\t" and character ~= "\r" and character ~= "\n" then
            table.insert(output, character)
        end
        index = index + 1
    end
    return table.concat(output)
end

local function EnsureBase64Lookup()
    if base64Lookup then
        return
    end
    base64Lookup = {}
    local index = 1
    while index <= string.len(base64Alphabet) do
        base64Lookup[string.sub(base64Alphabet, index, index)] = index - 1
        index = index + 1
    end
end

local function DecodeBase64(text)
    EnsureBase64Lookup()
    local total = string.len(text)
    if total == 0 or Remainder(total, 4) ~= 0 then
        return nil, "文本长度不正确"
    end
    local output = {}
    local position = 1
    while position <= total do
        local character1 = string.sub(text, position, position)
        local character2 = string.sub(text, position + 1, position + 1)
        local character3 = string.sub(text, position + 2, position + 2)
        local character4 = string.sub(text, position + 3, position + 3)
        local value1 = base64Lookup[character1]
        local value2 = base64Lookup[character2]
        local value3 = character3 == "=" and 0 or base64Lookup[character3]
        local value4 = character4 == "=" and 0 or base64Lookup[character4]
        if not value1 or not value2 or not value3 or not value4 then
            return nil, "文本包含无效字符"
        end
        if character3 == "=" and character4 ~= "=" then
            return nil, "文本结尾不完整"
        end
        if (character3 == "=" or character4 == "=") and position + 3 ~= total then
            return nil, "填充字符位置不正确"
        end

        local byte1 = value1 * 4 + math.floor(value2 / 16)
        table.insert(output, string.char(byte1))
        if character3 ~= "=" then
            local value2Low = value2 - math.floor(value2 / 16) * 16
            local byte2 = value2Low * 16 + math.floor(value3 / 4)
            table.insert(output, string.char(byte2))
        end
        if character4 ~= "=" then
            local value3Low = value3 - math.floor(value3 / 4) * 4
            local byte3 = value3Low * 64 + value4
            table.insert(output, string.char(byte3))
        end
        position = position + 4
    end
    return table.concat(output)
end

local function BytesToString(bytes)
    local output = {}
    local total = table.getn(bytes)
    local position = 1
    while position <= total do
        -- 旧客户端的 unpack 不可靠支持起止下标，逐字节转换可避免重复或截断。
        table.insert(output, string.char(bytes[position]))
        position = position + 1
    end
    return table.concat(output)
end

local function DecompressBinary(data)
    local output = {}
    local position = 1
    local total = string.len(data)
    while position <= total do
        local header = string.byte(data, position)
        position = position + 1
        if header < 128 then
            local literalLength = header + 1
            if position + literalLength - 1 > total then
                return nil, "压缩文本不完整"
            end
            local literalIndex = 0
            while literalIndex < literalLength do
                table.insert(output, string.byte(data, position + literalIndex))
                literalIndex = literalIndex + 1
            end
            position = position + literalLength
        else
            local matchLength = header - 128 + 3
            local matchOffset = string.byte(data, position)
            if not matchOffset or matchOffset < 1 or matchOffset > table.getn(output) then
                return nil, "压缩文本引用无效"
            end
            position = position + 1
            local matchIndex = 1
            while matchIndex <= matchLength do
                local sourceIndex = table.getn(output) - matchOffset + 1
                table.insert(output, output[sourceIndex])
                matchIndex = matchIndex + 1
            end
        end
        if table.getn(output) > 65535 then
            return nil, "导入内容超过安全限制"
        end
    end
    return BytesToString(output)
end

local function DeserializeProfile(data)
    local total = string.len(data)
    local position = 1
    local function ReadByte()
        local value = string.byte(data, position)
        position = position + 1
        return value
    end
    local function ReadString(length)
        if length < 0 or position + length - 1 > total then
            return nil
        end
        local value = string.sub(data, position, position + length - 1)
        position = position + length
        return value
    end
    local function ReadUnsigned16()
        local value = UnpackUnsigned16(data, position)
        position = position + 2
        return value
    end

    if ReadString(2) ~= "C2" then
        return nil, "配置版本不受支持"
    end
    local formatVersion = ReadByte()
    if formatVersion ~= 2 and formatVersion ~= 3 then
        return nil, "配置版本不受支持"
    end
    local classLength = ReadUnsigned16()
    local classFile = classLength and ReadString(classLength) or nil
    local nameLength = ReadUnsigned16()
    local profileName = nameLength and ReadString(nameLength) or nil
    local direction = nil
    local iconLimit = nil
    if formatVersion >= 3 then
        local directionFlag = ReadByte()
        iconLimit = ReadByte()
        if not directionFlag or directionFlag > 1 or not iconLimit or iconLimit < 1 or iconLimit > 10 then
            return nil, "快捷窗布局数据无效"
        end
        direction = directionFlag == 1 and "vertical" or "horizontal"
    end
    local stepTotal = ReadByte()
    if not classFile or classFile == "" or not profileName or profileName == "" or not stepTotal then
        return nil, "配置内容不完整"
    end
    if string.len(profileName) > 48 or stepTotal > 60 then
        return nil, "配置内容超过安全限制"
    end

    local steps = {}
    local stepIndex = 1
    while stepIndex <= stepTotal do
        local idLength = ReadUnsigned16()
        local cardId = idLength and ReadString(idLength) or nil
        local flags = ReadByte()
        if not cardId or cardId == "" or string.len(cardId) > 255 or not flags or flags > 3 then
            return nil, "卡片配置数据无效"
        end
        table.insert(steps, {
            id = cardId,
            enabled = Remainder(flags, 2) == 1 and 1 or 0,
            minimizedVisible = flags >= 2 and 1 or 0
        })
        stepIndex = stepIndex + 1
    end
    if position ~= total + 1 then
        return nil, "配置末尾包含额外数据"
    end
    return {
        name = profileName,
        classFile = classFile,
        steps = steps,
        direction = direction,
        iconLimit = iconLimit
    }
end

function Cat2.ImportConfigurationText(text)
    if type(text) ~= "string" then
        return nil, "没有可导入的文本"
    end
    local cleaned = RemoveCopyWhitespace(text)
    if string.len(cleaned) > 12000 then
        return nil, "导入文本超过长度限制"
    end
    local matchedPrefix = nil
    if string.sub(cleaned, 1, string.len(exportPrefix)) == exportPrefix then
        matchedPrefix = exportPrefix
    elseif string.sub(cleaned, 1, string.len(legacyExportPrefix)) == legacyExportPrefix then
        matchedPrefix = legacyExportPrefix
    end
    if not matchedPrefix then
        return nil, "这不是 Cat2 配置文本，或配置版本不受支持"
    end
    local encoded = string.sub(cleaned, string.len(matchedPrefix) + 1)
    local envelope, decodeError = DecodeBase64(encoded)
    if not envelope then
        return nil, decodeError
    end
    if string.len(envelope) < 5 then
        return nil, "导入文本不完整"
    end
    local expectedChecksum = UnpackUnsigned32(envelope, 1)
    local serialized, decompressError = DecompressBinary(string.sub(envelope, 5))
    if not serialized then
        return nil, decompressError
    end
    if CalculateChecksum(serialized) ~= expectedChecksum then
        return nil, "校验失败\n文本可能复制不完整或已被修改"
    end
    return DeserializeProfile(serialized)
end
