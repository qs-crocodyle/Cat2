-- CatThreatLite：可嵌入多个插件的轻量仇恨共享服务。
-- 每个插件都可以携带本文件；同一游戏会话只会创建一个全局实例、事件框架和查询节流器。

local globals = _G or getfenv()
local MODULE_REVISION = 10001
local service = globals.CatThreatLite

if type(service) == "table" and (tonumber(service.revision) or 0) >= MODULE_REVISION then
    -- 相同或更新版本已经由其他插件加载，直接共享现有实例。
    return
end

if type(service) ~= "table" then
    service = {}
    globals.CatThreatLite = service
elseif service._eventFrame then
    -- 较新副本可以原地升级共享表；先停掉旧事件框架，避免留下重复监听。
    if service._eventFrame.UnregisterAllEvents then
        service._eventFrame:UnregisterAllEvents()
    end
    if service._eventFrame.SetScript then
        service._eventFrame:SetScript("OnEvent", nil)
    end
end

local QUERY_PREFIX = "TWT_UDTSv4"
local RESPONSE_MARKER = "TWTv4="
local QUERY_INTERVAL = 0.75
local RESPONSE_TTL = 2
local TARGET_CHANGE_GRACE = 0.25

local cachedPercent = nil
local lastQueryAt = -100
local lastResponseAt = -100
local ignorePacketsUntil = 0
local targetKey = nil

local function GetGroupChannel()
    if GetNumRaidMembers() > 0 then
        return "RAID"
    end
    if GetNumPartyMembers() > 0 then
        return "PARTY"
    end
    return nil
end

local function GetTargetKey()
    local exists, guid = UnitExists("target")
    if not exists then
        return nil
    end
    if guid then
        return tostring(guid)
    end
    return tostring(UnitName("target") or "") .. ":" .. tostring(UnitLevel("target") or "")
end

local function ResetTargetState()
    local now = GetTime()
    targetKey = GetTargetKey()
    cachedPercent = nil
    lastResponseAt = -100
    lastQueryAt = now
    -- Threat API 的返回包不带目标 GUID。切换目标后短暂丢弃旧包，避免串目标。
    ignorePacketsUntil = now + TARGET_CHANGE_GRACE
end

local function EnsureTargetState()
    local currentKey = GetTargetKey()
    if currentKey ~= targetKey then
        ResetTargetState()
    end
end

local function CanQueryThreat()
    if not UnitExists("target") or UnitIsDead("target") then
        return false
    end
    if UnitIsPlayer("target") or not UnitCanAttack("player", "target") then
        return false
    end
    if not UnitAffectingCombat("target") then
        return false
    end
    return GetGroupChannel() ~= nil
end

local function FindPlayerPercent(packet)
    local markerStart = string.find(packet, RESPONSE_MARKER, 1, true)
    if not markerStart then
        return nil, false
    end

    local payload = string.sub(packet, markerStart + string.len(RESPONSE_MARKER))
    local tankModeStart = string.find(payload, "#", 1, true)
    if tankModeStart then
        payload = string.sub(payload, 1, tankModeStart - 1)
    end

    local playerName = UnitName("player")
    local entryStart = 1
    local payloadLength = string.len(payload)
    while entryStart <= payloadLength do
        local separator = string.find(payload, ";", entryStart, true)
        local entryEnd = separator and (separator - 1) or payloadLength
        local entry = string.sub(payload, entryStart, entryEnd)

        -- 返回格式：姓名:坦克标记:仇恨值:百分比:近战标记[:其他字段]
        local first = string.find(entry, ":", 1, true)
        local second = first and string.find(entry, ":", first + 1, true)
        local third = second and string.find(entry, ":", second + 1, true)
        local fourth = third and string.find(entry, ":", third + 1, true)
        if fourth and string.sub(entry, 1, first - 1) == playerName then
            return tonumber(string.sub(entry, third + 1, fourth - 1)), true
        end

        if not separator then
            break
        end
        entryStart = separator + 1
    end

    -- 服务端只返回限制数量内的成员；当前玩家不在列表时按 0% 处理。
    return 0, true
end

local function HandleThreatPacket(packet)
    if type(packet) ~= "string" or GetTime() < ignorePacketsUntil then
        return
    end
    EnsureTargetState()
    if not CanQueryThreat() then
        return
    end

    local percent, isThreatPacket = FindPlayerPercent(packet)
    if not isThreatPacket then
        return
    end
    cachedPercent = math.max(0, tonumber(percent) or 0)
    lastResponseAt = GetTime()
end

function service.GetPercent()
    EnsureTargetState()
    if not CanQueryThreat() then
        cachedPercent = nil
        return nil
    end

    local now = GetTime()
    if now - lastQueryAt >= QUERY_INTERVAL then
        local channel = GetGroupChannel()
        if channel then
            -- 单条请求、最多 12 名；与 TWThreat 的双请求和完整团队模型相比开销很小。
            pcall(SendAddonMessage, QUERY_PREFIX, "limit=12", channel)
            lastQueryAt = now
        end
    end

    if cachedPercent ~= nil and now - lastResponseAt <= RESPONSE_TTL then
        return cachedPercent
    end
    return nil
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function()
    if event == "CHAT_MSG_ADDON" then
        HandleThreatPacket(arg2)
    else
        ResetTargetState()
    end
end)

-- 元数据最后写入，避免文件加载中途失败时留下一个看似可用的半成品版本。
service.name = "CatThreatLite"
service.revision = MODULE_REVISION
service.protocolVersion = 4
service.queryInterval = QUERY_INTERVAL
service._eventFrame = eventFrame
