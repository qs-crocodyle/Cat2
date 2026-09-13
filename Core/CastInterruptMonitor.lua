-- 共享施法中断监控器。
-- 卡片只声明技能能力与被动规则；监控器统一跟踪玩家读条及技能的实际目标。
--
-- 两阶段模型：UNIT_CASTEVENT/OnUpdate 负责识别读条、锁定真实施法目标并设置 interruptRequested；
-- 下一次 /cat2 宏进入 ConfigurationRunner 后，TryExecutePendingCastInterrupt 才调用 SpellStopCasting。
-- 这样既遵守客户端的受保护操作限制，也能在中断后立刻结束本轮，防止后续卡片重新起手施法。
-- 新增中断条件应通过 RegisterCastInterruptRule 扩展，不要把职业或具体技能硬编码进本文件。
Cat2 = Cat2 or {}

local monitorFrame = CreateFrame("Frame", "Cat2CastInterruptMonitorFrame")
local castProfilesBySpellName = {}
local ruleEvaluators = {}
local activeCast = nil
local pendingCastTarget = nil
local updateElapsed = 0
local lastInterrupt = nil
local reportedErrors = {}

local function GetPlayerGuid()
    local basic = Cat2.PlayerInformation and Cat2.PlayerInformation.basic
    if basic and basic.guid then
        return basic.guid
    end
    local exists
    local playerGuid
    exists, playerGuid = UnitExists("player")
    return playerGuid
end

local function GetPlayerClassFile()
    local basic = Cat2.PlayerInformation and Cat2.PlayerInformation.basic
    if basic and basic.classFile then
        return basic.classFile
    end
    local localizedClass
    local classFile
    localizedClass, classFile = UnitClass("player")
    return classFile
end

local function CardSupportsCurrentPlayer(card)
    if not card then
        return false
    end
    if card.category == "common" or card.category == "logic" or card.category == "item" then
        return true
    end
    return Cat2.GetCardSpecializationForClass(card, GetPlayerClassFile()) ~= nil
end

local function GetSpellNameById(spellId)
    local spellName
    if type(GetSpellNameAndRankForId) == "function" then
        spellName = GetSpellNameAndRankForId(spellId)
    end
    if not spellName and type(SpellInfo) == "function" then
        spellName = SpellInfo(spellId)
    end
    return spellName
end

local function NormalizeSpellName(spellName)
    if type(spellName) ~= "string" then
        return nil
    end
    local rankStart = string.find(spellName, "(", 1, true)
    if rankStart then
        return string.sub(spellName, 1, rankStart - 1)
    end
    return spellName
end

-- 卡片施法函数在临时切换目标前记录真正使用的单位；事件 GUID 仍用于身份校验。
function Cat2.RecordPendingCastTarget(spellName, unit)
    if type(unit) ~= "string" or unit == "" then
        pendingCastTarget = nil
        return false
    end
    local exists
    local targetGuid
    exists, targetGuid = UnitExists(unit)
    if not exists then
        pendingCastTarget = nil
        return false
    end
    pendingCastTarget = {
        spellName = NormalizeSpellName(spellName),
        unit = unit,
        targetGuid = targetGuid,
        recordedAt = GetTime(),
    }
    return true
end

local function ConsumePendingCastTarget(spellName, eventTargetGuid)
    local pending = pendingCastTarget
    pendingCastTarget = nil
    if not pending or GetTime() - pending.recordedAt > 3 then
        return nil, eventTargetGuid
    end
    if pending.spellName ~= spellName then
        return nil, eventTargetGuid
    end
    if eventTargetGuid and pending.targetGuid and eventTargetGuid ~= pending.targetGuid then
        return nil, eventTargetGuid
    end
    return pending.unit, pending.targetGuid or eventTargetGuid
end

-- 注册卡片描述的技能能力。能力本身不会启用任何中断行为。
function Cat2.RegisterCardCastProfile(card)
    local castProfile = card and card.castProfile
    if type(castProfile) ~= "table" or type(castProfile.spellNames) ~= "table" then
        return false
    end
    if type(castProfile.tags) ~= "table" then
        return false
    end

    local spellIndex = 1
    local spellTotal = table.getn(castProfile.spellNames)
    local registered = false
    while spellIndex <= spellTotal do
        local spellName = castProfile.spellNames[spellIndex]
        if type(spellName) == "string" and spellName ~= "" then
            local profiles = castProfilesBySpellName[spellName]
            if type(profiles) ~= "table" then
                profiles = {}
                castProfilesBySpellName[spellName] = profiles
            end
            table.insert(profiles, {
                card = card,
                tags = castProfile.tags,
            })
            registered = true
        end
        spellIndex = spellIndex + 1
    end
    return registered
end

function Cat2.RegisterCastInterruptRule(ruleType, evaluator)
    if type(ruleType) ~= "string" or ruleType == "" or type(evaluator) ~= "function" then
        return false
    end
    ruleEvaluators[ruleType] = evaluator
    return true
end

local function SpellHasTag(spellName, tag)
    local profiles = castProfilesBySpellName[spellName]
    if type(profiles) ~= "table" or type(tag) ~= "string" then
        return false
    end

    local profileIndex = 1
    local profileTotal = table.getn(profiles)
    while profileIndex <= profileTotal do
        local profile = profiles[profileIndex]
        if profile and profile.tags and profile.tags[tag] == true and CardSupportsCurrentPlayer(profile.card) then
            return true
        end
        profileIndex = profileIndex + 1
    end
    return false
end

local function GetActivePolicies(spellName)
    local policies = {}
    local repository = Cat2.RuntimeConfigurations
    if type(repository) ~= "table" or type(repository.profiles) ~= "table" then
        return policies, nil
    end

    local profileId = repository.activeProfileId
    local profile = repository.profiles[profileId]
    if type(profile) ~= "table" or type(profile.steps) ~= "table" then
        return policies, profileId
    end

    local stepIndex = 1
    local stepTotal = table.getn(profile.steps)
    while stepIndex <= stepTotal do
        local step = profile.steps[stepIndex]
        if step and step.enabled ~= 0 then
            local definition = Cat2.CardRegistry and Cat2.CardRegistry.ById[step.id]
            local policy = definition and definition.castInterruptPolicy
            if definition and definition.behavior == "passive" and type(policy) == "table" then
                local included = true
                if type(policy.matchTag) == "string" then
                    included = SpellHasTag(spellName, policy.matchTag)
                end
                if included and type(policy.includeSpells) == "table" then
                    included = policy.includeSpells[spellName] == true
                end
                if included and type(policy.excludeSpells) == "table" and policy.excludeSpells[spellName] == true then
                    included = false
                end
                if included then
                    table.insert(policies, {
                        step = step,
                        card = definition,
                        policy = policy,
                    })
                end
            end
        end
        stepIndex = stepIndex + 1
    end
    return policies, profileId
end

local function ReportRuleError(card, ruleType, errorMessage)
    local cardId = card and card.id or "unknown"
    local errorKey = cardId .. "|" .. tostring(ruleType)
    if reportedErrors[errorKey] then
        return
    end
    reportedErrors[errorKey] = true
    DEFAULT_CHAT_FRAME:AddMessage(
        "|cffff5555Cat2：施法中断规则执行失败「" .. (card and card.name or cardId) .. "」：|r" .. tostring(errorMessage)
    )
end

local function EvaluateRule(castState, policyRecord, rule)
    if type(rule) ~= "table" or type(rule.type) ~= "string" then
        return false, nil
    end
    local evaluator = ruleEvaluators[rule.type]
    if type(evaluator) ~= "function" then
        return false, nil
    end

    local succeeded, shouldInterrupt, reason = pcall(evaluator, castState, rule, policyRecord.step)
    if not succeeded then
        ReportRuleError(policyRecord.card, rule.type, shouldInterrupt)
        return false, nil
    end
    if shouldInterrupt == true then
        return true, reason or rule.reason
    end
    return false, nil
end

local function EvaluatePolicy(castState, policyRecord)
    local policy = policyRecord.policy
    local rules = policy.rules
    if type(rules) ~= "table" then
        return false, nil
    end

    local ruleIndex = 1
    local ruleTotal = table.getn(rules)
    if ruleTotal == 0 then
        return false, nil
    end

    if policy.mode == "all" then
        local finalReason = nil
        while ruleIndex <= ruleTotal do
            local matched, reason = EvaluateRule(castState, policyRecord, rules[ruleIndex])
            if not matched then
                return false, nil
            end
            finalReason = reason or finalReason
            ruleIndex = ruleIndex + 1
        end
        return true, finalReason
    end

    while ruleIndex <= ruleTotal do
        local matched, reason = EvaluateRule(castState, policyRecord, rules[ruleIndex])
        if matched then
            return true, reason
        end
        ruleIndex = ruleIndex + 1
    end
    return false, nil
end

local function StopMonitoring()
    activeCast = nil
    updateElapsed = 0
    monitorFrame:SetScript("OnUpdate", nil)
end

local function ResolveCastTarget(castState)
    local targetUnit = castState.targetUnit
    if targetUnit and UnitExists(targetUnit) then
        local exists
        local currentGuid
        exists, currentGuid = UnitExists(targetUnit)
        if exists and (not castState.targetGuid or not currentGuid or currentGuid == castState.targetGuid) then
            return targetUnit
        end
    end
    if castState.targetGuid and UnitExists(castState.targetGuid) then
        return castState.targetGuid
    end
    return nil
end

local function MonitorOnUpdate()
    if not activeCast then
        StopMonitoring()
        return
    end

    updateElapsed = updateElapsed + arg1
    if updateElapsed < 0.1 then
        return
    end
    updateElapsed = 0

    if GetTime() - activeCast.startedAt > 30 then
        StopMonitoring()
        return
    end

    local policies, profileId = GetActivePolicies(activeCast.spellName)
    if profileId ~= activeCast.profileId or table.getn(policies) == 0 then
        StopMonitoring()
        return
    end

    activeCast.policies = policies
    if activeCast.interruptRequested then
        -- 异步事件与 OnUpdate 只保留请求；受保护的停止施法留给下一次宏按键执行。
        return
    end

    local policyIndex = 1
    local policyTotal = table.getn(policies)
    while policyIndex <= policyTotal do
        local matched, reason = EvaluatePolicy(activeCast, policies[policyIndex])
        if matched then
            lastInterrupt = {
                spellId = activeCast.spellId,
                spellName = activeCast.spellName,
                targetGuid = activeCast.targetGuid,
                castType = activeCast.castType,
                reason = reason,
                time = GetTime(),
            }
            activeCast.interruptRequested = true
            return
        end
        policyIndex = policyIndex + 1
    end
end

local function StartMonitoring(spellId, spellName, targetUnit, targetGuid, castType, policies, profileId)
    activeCast = {
        spellId = spellId,
        spellName = spellName,
        targetUnit = targetUnit,
        targetGuid = targetGuid,
        castType = castType,
        policies = policies,
        profileId = profileId,
        startedAt = GetTime(),
    }
    updateElapsed = 0.1
    monitorFrame:SetScript("OnUpdate", MonitorOnUpdate)
end

function Cat2.GetActiveCastInterruptState()
    return activeCast
end

function Cat2.GetLastCastInterruptState()
    return lastInterrupt
end

-- 必须由宏命令的按键执行链调用；事件和 OnUpdate 中直接停止施法可能被客户端保护。
function Cat2.TryExecutePendingCastInterrupt()
    if not activeCast or activeCast.interruptRequested ~= true then
        return false
    end
    local interruptInformation = lastInterrupt
    -- 先通知查看施法卡片记录本次 Cat2 主动中断，随后产生的 FAIL 事件即可识别并去重。
    if interruptInformation and Cat2.DispatchCardInternalEvent then
        Cat2.DispatchCardInternalEvent("CAT2_CAST_INTERRUPTED", interruptInformation)
    end
    SpellStopCasting()
    StopMonitoring()
    return true
end

Cat2.RegisterCastInterruptRule("targetHealthAtLeast", function(castState, rule)
    local castTarget = ResolveCastTarget(castState)
    if not castTarget then
        return false
    end
    local maximumHealth = UnitHealthMax(castTarget) or 0
    if maximumHealth <= 0 then
        return false
    end
    local currentHealth = UnitHealth(castTarget) or 0
    local threshold = tonumber(rule.value) or 100
    if currentHealth * 100 >= maximumHealth * threshold then
        return true, rule.reason or "技能目标血量达到中断条件"
    end
    return false
end)

Cat2.RegisterOptionalEvent(monitorFrame, "UNIT_CASTEVENT")
monitorFrame:SetScript("OnEvent", function()
    if event ~= "UNIT_CASTEVENT" or arg1 ~= GetPlayerGuid() then
        return
    end

    local castType = arg3
    local spellId = arg4
    if castType == "START" or castType == "CHANNEL" then
        local spellName = GetSpellNameById(spellId)
        if not spellName then
            StopMonitoring()
            return
        end
        local policies, profileId = GetActivePolicies(spellName)
        if table.getn(policies) == 0 then
            StopMonitoring()
            return
        end
        local targetUnit, targetGuid = ConsumePendingCastTarget(spellName, arg2)
        StartMonitoring(spellId, spellName, targetUnit, targetGuid, castType, policies, profileId)
        return
    end

    if castType == "CAST" or castType == "FAIL" then
        if activeCast then
            -- 读条期间可能穿插被动或装备触发的 CAST；只有同一技能才能结束当前监控。
            if not spellId or activeCast.spellId == spellId then
                StopMonitoring()
            end
        else
            pendingCastTarget = nil
        end
    end
end)
