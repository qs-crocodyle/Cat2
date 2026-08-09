-- 配置流程执行器与聊天指令入口。
-- 本文件在 FlowEditor 之后加载，以便读取 Cat2.RuntimeConfigurations 的当前流程数据。
-- 每次 /cat2 配置名 执行时，仅在整轮开始前刷新一次 PlayerInformation.temporary；
-- 所有卡片共享这份快照，避免逐卡刷新造成额外 API 调用与前后状态不一致。
Cat2 = Cat2 or {}

-- 去掉聊天指令参数首尾的空格与制表符。
local function TrimCommandText(text)
    local firstIndex = 1
    local lastIndex = string.len(text)
    while firstIndex <= lastIndex do
        local character = string.sub(text, firstIndex, firstIndex)
        if character ~= " " and character ~= "\t" then
            break
        end
        firstIndex = firstIndex + 1
    end
    while lastIndex >= firstIndex do
        local character = string.sub(text, lastIndex, lastIndex)
        if character ~= " " and character ~= "\t" then
            break
        end
        lastIndex = lastIndex - 1
    end
    return string.sub(text, firstIndex, lastIndex)
end

-- 按显示名称查找配置；遍历 profileOrder 可保证遵循仓库的正式顺序。
function Cat2.FindConfigurationByName(configurationName)
    if Cat2.EnsureConfigurationDataLoaded then
        Cat2.EnsureConfigurationDataLoaded()
    end
    local repository = Cat2.RuntimeConfigurations
    if not repository or not repository.profileOrder or not repository.profiles then
        return nil
    end
    local orderIndex = 1
    local orderTotal = table.getn(repository.profileOrder)
    while orderIndex <= orderTotal do
        local profileId = repository.profileOrder[orderIndex]
        local profile = repository.profiles[profileId]
        if profile and profile.name == configurationName then
            return profile
        end
        orderIndex = orderIndex + 1
    end
    return nil
end

-- 每轮执行前只扫描一次流程，供普通卡片快速判断某个卡片 ID 是否存在。
local function CreateCardLookup(steps)
    local cardLookup = {}
    local activeCardLookup = {}
    local stepIndex = 1
    local stepTotal = table.getn(steps)
    while stepIndex <= stepTotal do
        local step = steps[stepIndex]
        local cardId = step and step.id
        if type(cardId) == "string" and cardId ~= "" then
            cardLookup[cardId] = true
            if step.enabled ~= 0 then
                activeCardLookup[cardId] = true
            end
        end
        stepIndex = stepIndex + 1
    end
    return cardLookup, activeCardLookup
end

-- 调试窗口打开时，向聊天框记录本轮实际进入的流程步骤。
-- 调试状态由 PlayerDebug.lua 提供；窗口关闭时本函数不产生任何输出。
local function PrintDebugStep(phase, stepIndex, stepTotal, step)
    if not Cat2.UI or not Cat2.UI.IsPlayerDebugWindowVisible then
        return
    end
    if not Cat2.UI.IsPlayerDebugWindowVisible() then
        return
    end
    local stepName = step and (step.name or step.id) or Cat2.L("未命名卡片")
    local stepId = step and step.id or Cat2.L("未知ID")
    DEFAULT_CHAT_FRAME:AddMessage("|cff6fc7ff" .. Cat2.L("Cat2 调试") .. "|r " .. phase .. " " .. stepIndex .. "/" .. stepTotal .. "：|cffffff66" .. stepName .. "|r |cff8e9baa[" .. stepId .. "]|r")
end

-- 创建单个成员的本轮只读快照；同一 unit 在不同排序列表中共用这个对象。
local function GetOrCreateTeamMember(snapshot, unit)
    local existing = snapshot.units[unit]
    if existing then
        return existing
    end

    local health = UnitHealth(unit) or 0
    local maxHealth = UnitHealthMax(unit) or 0
    local healthPercent = 0
    if maxHealth > 0 then
        healthPercent = health / maxHealth * 100
    end

    local member = {
        unit = unit,
        name = UnitName(unit),
        health = health,
        maxHealth = maxHealth,
        missingHealth = maxHealth - health,
        healthPercent = healthPercent,
        isPlayer = UnitIsUnit(unit, "player") and true or false,
        dead = UnitIsDeadOrGhost(unit) and true or false,
        visible = UnitIsVisible(unit) and true or false,
        rangeChecked = false,
        distance = nil,
        inSight = nil
    }
    snapshot.units[unit] = member
    return member
end

-- 小队与团队范围按需建立；没有治疗卡请求时不会扫描任何队伍成员。
local function BuildTeamScope(snapshot, scope)
    local cached = snapshot.base[scope]
    if cached then
        return cached
    end

    local members = {}
    if scope == "party" then
        table.insert(members, GetOrCreateTeamMember(snapshot, "player"))
        local partyIndex = 1
        local partyTotal = GetNumPartyMembers()
        while partyIndex <= partyTotal do
            local unit = "party" .. partyIndex
            if UnitExists(unit) and UnitIsVisible(unit) then
                table.insert(members, GetOrCreateTeamMember(snapshot, unit))
            end
            partyIndex = partyIndex + 1
        end
    elseif scope == "group" then
        local raidTotal = GetNumRaidMembers()
        if raidTotal > 0 then
            local raidIndex = 1
            while raidIndex <= raidTotal do
                local unit = "raid" .. raidIndex
                if UnitExists(unit) and UnitIsVisible(unit) then
                    table.insert(members, GetOrCreateTeamMember(snapshot, unit))
                end
                raidIndex = raidIndex + 1
            end
        else
            local partyIndex = 1
            local partyTotal = GetNumPartyMembers()
            while partyIndex <= partyTotal do
                local unit = "party" .. partyIndex
                if UnitExists(unit) and UnitIsVisible(unit) then
                    table.insert(members, GetOrCreateTeamMember(snapshot, unit))
                end
                partyIndex = partyIndex + 1
            end
            table.insert(members, GetOrCreateTeamMember(snapshot, "player"))
        end
    end

    snapshot.base[scope] = members
    return members
end

local function CopyTeamMembers(source)
    local result = {}
    local memberIndex = 1
    local memberTotal = table.getn(source)
    while memberIndex <= memberTotal do
        result[memberIndex] = source[memberIndex]
        memberIndex = memberIndex + 1
    end
    return result
end

-- 返回本轮缓存的成员排列；返回表与成员对象均应按只读方式使用。
local emptyTeamMembers = {}

local function GetTeamMembers(context, scope, order)
    if scope ~= "party" and scope ~= "group" then
        return emptyTeamMembers
    end
    if order ~= "health" and order ~= "maxHealth" and order ~= "random" then
        order = "original"
    end

    local snapshot = context.teamSnapshot
    if not snapshot then
        snapshot = {
            units = {},
            base = {},
            ordered = {}
        }
        context.teamSnapshot = snapshot
    end
    local orders = snapshot.ordered[scope]
    if not orders then
        orders = {}
        snapshot.ordered[scope] = orders
    end
    if orders[order] then
        return orders[order]
    end

    local base = BuildTeamScope(snapshot, scope)
    local result = base
    if order ~= "original" then
        result = CopyTeamMembers(base)
    end

    if order == "health" then
        table.sort(result, function(left, right)
            return left.healthPercent < right.healthPercent
        end)
    elseif order == "maxHealth" then
        table.sort(result, function(left, right)
            return left.maxHealth > right.maxHealth
        end)
    elseif order == "random" then
        local shuffleIndex = table.getn(result)
        while shuffleIndex >= 2 do
            local targetIndex = math.random(1, shuffleIndex)
            result[shuffleIndex], result[targetIndex] = result[targetIndex], result[shuffleIndex]
            shuffleIndex = shuffleIndex - 1
        end
    end

    orders[order] = result
    return result
end

-- 距离与视野只在调用方真正需要时检查，并由所有排序列表共用结果。
local function GetTeamMemberRange(member)
    if type(member) ~= "table" or type(member.unit) ~= "string" then
        return nil, nil
    end
    if member.rangeChecked then
        return member.distance, member.inSight
    end

    member.rangeChecked = true
    if member.unit == "player" then
        member.distance = 0
        member.inSight = true
    elseif Cat2.UnitXP and type(UnitXP) == "function" then
        member.distance = UnitXP("distanceBetween", "player", member.unit)
        member.inSight = UnitXP("inSight", "player", member.unit)
    else
        member.distance = nil
        member.inSight = true
    end
    return member.distance, member.inSight
end

-- 被动卡片先扫描整个配置并建立共享 context，因此其效果不受自身排列位置限制。
-- 随后 Validate 统一决定流程能否运行，最后才从上往下调用普通卡片 Execute(context)。
function Cat2.ExecuteConfiguration(configurationName)
    local profile = Cat2.FindConfigurationByName(configurationName)
    if not profile then
        return false, 0, 0
    end
    if Cat2.UI and Cat2.UI.TriggerShortcutWindowTitleLight then
        Cat2.UI.TriggerShortcutWindowTitleLight(profile.id)
    end
    -- 每次触发配置时统一刷新一次临时角色信息，供本轮所有卡片读取同一份最新快照。
    if Cat2.RefreshPlayerTemporaryInformation then
        Cat2.RefreshPlayerTemporaryInformation()
    end
    local executedTotal = 0
    local failedTotal = 0
    local failedNames = {}
    local stopped = false
    local cardLookup, activeCardLookup = CreateCardLookup(profile.steps)
    local context = {
        profileId = profile.id,
        profileName = profile.name,
        profile = profile,
        player = "player",
        target = "target",
        playerInformation = Cat2.PlayerInformation,
        parameters = {},
        passiveCards = {},
        teamSnapshot = nil
    }
    function context:HasCard(cardId)
        return cardLookup[cardId] == true
    end
    function context:IsCardActive(cardId)
        return activeCardLookup[cardId] == true
    end
    -- scope：party/group；order：original/health/maxHealth/random。
    function context:GetTeamMembers(scope, order)
        return GetTeamMembers(self, scope, order)
    end
    function context:GetTeamMemberRange(member)
        return GetTeamMemberRange(member)
    end
    -- 除函数参数外也保留本轮全局引用，便于旧卡片逐步迁移；执行结束后立即清除。
    Cat2.CurrentExecutionContext = context

    local stepTotal = table.getn(profile.steps)
    local stepIndex = 1
    while stepIndex <= stepTotal do
        local step = profile.steps[stepIndex]
        if step and step.enabled ~= 0 and step.behavior == "passive" then
            PrintDebugStep(Cat2.L("被动"), stepIndex, stepTotal, step)
            table.insert(context.passiveCards, step)
            executedTotal = executedTotal + 1
            if type(step.Apply) == "function" then
                local succeeded, applyError = pcall(step.Apply, context, step)
                if not succeeded then
                    failedTotal = failedTotal + 1
                    local stepName = step.name or step.id or Cat2.L("未命名被动卡片")
                    table.insert(failedNames, stepName)
                    DEFAULT_CHAT_FRAME:AddMessage("|cffff5555" .. Cat2.L("Cat2：被动卡片「") .. stepName .. Cat2.L("」应用失败：") .. "|r" .. tostring(applyError))
                    stopped = true
                    Cat2.CurrentExecutionContext = nil
                    return true, executedTotal, failedTotal, stopped, failedNames
                end
            end
        end
        stepIndex = stepIndex + 1
    end

    local passiveIndex = 1
    local passiveTotal = table.getn(context.passiveCards)
    while passiveIndex <= passiveTotal do
        local passive = context.passiveCards[passiveIndex]
        if type(passive.Validate) == "function" then
            local succeeded, allowed, reason = pcall(passive.Validate, context, passive)
            if not succeeded then
                failedTotal = failedTotal + 1
                local stepName = passive.name or passive.id or Cat2.L("未命名被动卡片")
                table.insert(failedNames, stepName)
                -- 错误标题和详细信息分行输出，避免较长的文件路径挤占标题空间。
                DEFAULT_CHAT_FRAME:AddMessage("|cffff5555" .. Cat2.L("Cat2：被动卡片「") .. stepName .. Cat2.L("」检查失败：") .. "|r")
                DEFAULT_CHAT_FRAME:AddMessage("|cffffffff" .. tostring(allowed) .. "|r")
                stopped = true
                Cat2.CurrentExecutionContext = nil
                return true, executedTotal, failedTotal, stopped, failedNames
            elseif allowed == false then
                if type(reason) == "string" and reason ~= "" then
                    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc33Cat2：" .. reason .. "|r")
                end
                stopped = true
                Cat2.CurrentExecutionContext = nil
                return true, executedTotal, failedTotal, stopped, failedNames
            end
        end
        passiveIndex = passiveIndex + 1
    end

    stepIndex = 1
    while stepIndex <= stepTotal do
        local step = profile.steps[stepIndex]
        if step and step.enabled ~= 0 and step.behavior ~= "passive" and type(step.Execute) == "function" then
            PrintDebugStep(Cat2.L("执行"), stepIndex, stepTotal, step)
            local succeeded, executeResult = pcall(step.Execute, context)
            executedTotal = executedTotal + 1
            if not succeeded then
                failedTotal = failedTotal + 1
                local stepName = step.name or step.id or Cat2.L("未命名卡片")
                table.insert(failedNames, stepName)
                -- 详细错误单独占一行，让聊天框可以按自身宽度完整换行。
                DEFAULT_CHAT_FRAME:AddMessage("|cffff5555" .. Cat2.L("Cat2：卡片「") .. stepName .. Cat2.L("」执行失败：") .. "|r")
                DEFAULT_CHAT_FRAME:AddMessage("|cffffffff" .. tostring(executeResult) .. "|r")
            elseif executeResult == true then
                stopped = true
                break
            end
        end
        stepIndex = stepIndex + 1
    end
    Cat2.CurrentExecutionContext = nil
    return true, executedTotal, failedTotal, stopped, failedNames
end

-- 注册旧版客户端聊天指令：/cat2 配置名
SLASH_CAT2CONFIGURATION1 = "/cat2"
SlashCmdList["CAT2CONFIGURATION"] = function(message)
    local configurationName = TrimCommandText(message or "")
    if configurationName == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc33" .. Cat2.L("Cat2：请输入配置名，例如 /cat2 配置1") .. "|r")
        if Cat2.UI and Cat2.UI.ShowMainWindow then
            Cat2.UI.ShowMainWindow()
        end
        return
    end
    -- debug 是保留参数，用于随时打开或关闭玩家信息调试窗。
    if string.lower(configurationName) == "debug" then
        if Cat2.UI and Cat2.UI.TogglePlayerDebugWindow then
            Cat2.UI.TogglePlayerDebugWindow()
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff5555" .. Cat2.L("Cat2：调试窗尚未加载，请完整重启游戏。") .. "|r")
        end
        return
    end
    if string.sub(string.lower(configurationName), 1, 4) == "lang" then
        local lang = TrimCommandText(string.sub(configurationName, 5))
        Cat2.SetLocale(lang)
        return
    end
    local found, executedTotal, failedTotal, stopped, failedNames = Cat2.ExecuteConfiguration(configurationName)
    if not found then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff5555" .. Cat2.L("Cat2：找不到配置「") .. configurationName .. Cat2.L("」。") .. "|r")
        return
    end
    if failedTotal > 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc33" .. Cat2.L("Cat2：配置「") .. configurationName .. Cat2.L("」执行完成，共调用 ") .. executedTotal .. Cat2.L(" 张卡片，其中 ") .. failedTotal .. Cat2.L(" 张失败。") .. "|r")
        if failedNames and table.getn(failedNames) > 0 then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff7777" .. Cat2.L("Cat2：失败卡片：") .. "|r|cffffaaaa" .. "\"" .. table.concat(failedNames, "\", \"") .. "\"" .. "|r")
        end
    end
end
