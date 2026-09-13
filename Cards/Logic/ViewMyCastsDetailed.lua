-- 详细查看玩家施法：保留 UNIT_CASTEVENT 提供的全部玩家施法与触发效果。
local card = {
    id = "common_view_my_casts_detailed",
    name = "查看我的施法（详细）",
    description = "显示玩家施法及触发的完整事件信息",
    details = "监听玩家的完整施法事件，包括主动技能、被动效果和触发特效，并将技能名、等级和目标打印到聊天框。聊天窗口留空时沿用默认聊天框；填写窗口标签名后会尝试输出到对应聊天窗口，找不到时回退默认聊天框。仅在当前流程启用时生效。",
    sort = 920,
    behavior = "passive",
    unique = true,
    category = "logic",
    icons = {
        "Interface\\Icons\\Spell_Holy_MagicalSentry",
    },
    events = {
        "UNIT_CASTEVENT",
        "CAT2_CAST_INTERRUPTED",
    },
    optionSchema = {
        {
            key = "chatFrameName",
            type = "string",
            label = "聊天窗口",
            shortLabel = "窗口",
            default = "",
        },
    },
}

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

local function GetSpellNameAndRank(spellId)
    local spellName
    local spellRank
    if type(GetSpellNameAndRankForId) == "function" then
        spellName, spellRank = GetSpellNameAndRankForId(spellId)
    end
    if not spellName and type(SpellInfo) == "function" then
        spellName, spellRank = SpellInfo(spellId)
    end
    return spellName, spellRank
end

local targetClassColors = {
    WARRIOR = "ffc79c6e",
    PALADIN = "fff58cba",
    HUNTER = "ffabd473",
    ROGUE = "fffff569",
    PRIEST = "ffffffff",
    SHAMAN = "ff0070de",
    MAGE = "ff69ccf0",
    WARLOCK = "ff9482c9",
    DRUID = "ffff7d0a",
}

local function GetTargetInformation(targetGuid)
    if not targetGuid or not UnitExists(targetGuid) then
        return nil, nil, nil
    end
    local targetName = UnitName(targetGuid)
    local localizedClass, classFile = UnitClass(targetGuid)
    local colorCode = targetClassColors[classFile]
    if not colorCode then
        if classFile or UnitCanAttack("player", targetGuid) then
            colorCode = "ffb56a5f"
        else
            colorCode = "ff80d080"
        end
    end
    return targetName, classFile, colorCode
end

local function PrintToConfiguredChatFrame(state, text)
    local channelName = ""
    if state and state.activeStep then
        channelName = Cat2.ResolveStepOption(state.activeStep, "chatFrameName") or ""
    end
    if channelName ~= "" and Cat2.AddMessageToChatFrame(text, channelName) then
        return
    end
    DEFAULT_CHAT_FRAME:AddMessage(text)
end

local function PrintCast(state, castState, targetGuid, spellId)
    local spellName, spellRank = GetSpellNameAndRank(spellId)
    if not spellName then
        spellName = "未知技能"
    end

    local targetName, targetClassFile, targetColorCode = GetTargetInformation(targetGuid)

    state.lastSpellId = spellId
    state.lastSpellName = spellName
    state.lastSpellRank = spellRank
    state.lastTargetGuid = targetGuid
    state.lastTargetName = targetName
    state.lastTargetClassFile = targetClassFile
    state.lastCastState = castState
    state.lastCastTime = GetTime()
    state.castCount = (state.castCount or 0) + 1

    local stateText = "|cff68d391[瞬发]|r "
    if castState == "START" then
        stateText = "|cff63b3ed[读条]|r "
    elseif castState == "CHANNEL" then
        stateText = "|cffb794f4[引导]|r "
    end

    local displayText = stateText .. "|cffffd45a" .. spellName .. "|r"
    if spellRank and spellRank ~= "" then
        displayText = displayText .. "|cffb8c7d9（" .. tostring(spellRank) .. "）|r"
    end
    if targetName and targetName ~= "" then
        displayText = displayText .. "|cff718096 → |r|c" .. targetColorCode .. "[" .. targetName .. "]|r"
    end
    PrintToConfiguredChatFrame(state, "|cff66ccffCat2：|r" .. displayText)
end

local function PrintInterrupted(state, interruptInformation)
    if type(interruptInformation) ~= "table" then
        return
    end
    local spellId = interruptInformation.spellId
    local spellName, spellRank = GetSpellNameAndRank(spellId)
    spellName = spellName or interruptInformation.spellName or "未知技能"
    local targetName, targetClassFile, targetColorCode = GetTargetInformation(interruptInformation.targetGuid)

    state.lastSpellId = spellId
    state.lastSpellName = spellName
    state.lastSpellRank = spellRank
    state.lastTargetGuid = interruptInformation.targetGuid
    state.lastTargetName = targetName
    state.lastTargetClassFile = targetClassFile
    state.lastCastState = "INTERRUPTED"
    state.lastCastTime = GetTime()
    state.lastInterruptSpellId = spellId
    state.lastInterruptTime = state.lastCastTime

    local displayText = "|cffff7777[中断]|r |cffffd45a" .. spellName .. "|r"
    if spellRank and spellRank ~= "" then
        displayText = displayText .. "|cffb8c7d9（" .. tostring(spellRank) .. "）|r"
    end
    if targetName and targetName ~= "" then
        displayText = displayText .. "|cff718096 → |r|c" .. targetColorCode .. "[" .. targetName .. "]|r"
    end
    if interruptInformation.reason and interruptInformation.reason ~= "" then
        displayText = displayText .. " |cff718096原因：|r|cffffb86b" .. tostring(interruptInformation.reason) .. "|r"
    end
    PrintToConfiguredChatFrame(state, "|cff66ccffCat2：|r" .. displayText)
end

function card.OnEvent(state, eventName, sourceGuid, targetGuid, castState, spellId)
    if eventName == "CAT2_CAST_INTERRUPTED" then
        PrintInterrupted(state, sourceGuid)
        return
    end
    if eventName ~= "UNIT_CASTEVENT" or sourceGuid ~= GetPlayerGuid() then
        return
    end

    if castState == "START" or castState == "CHANNEL" then
        state.pendingSpellId = spellId
        state.pendingTargetGuid = targetGuid
        state.pendingStartedAt = GetTime()
        PrintCast(state, castState, targetGuid, spellId)
        return
    end

    if castState == "FAIL" then
        local pendingSpellId = state.pendingSpellId
        local pendingTargetGuid = state.pendingTargetGuid
        local interrupted = pendingSpellId and (not spellId or pendingSpellId == spellId)
        local alreadyReported = interrupted
            and state.lastInterruptSpellId == pendingSpellId
            and GetTime() - (state.lastInterruptTime or 0) <= 1
        state.pendingSpellId = nil
        state.pendingTargetGuid = nil
        state.pendingStartedAt = nil
        if interrupted and not alreadyReported then
            PrintInterrupted(state, {
                spellId = pendingSpellId,
                targetGuid = pendingTargetGuid,
            })
        end
        return
    end

    if castState ~= "CAST" then
        return
    end

    local pendingStartedAt = state.pendingStartedAt or 0
    if state.pendingSpellId == spellId and GetTime() - pendingStartedAt <= 60 then
        state.pendingSpellId = nil
        state.pendingTargetGuid = nil
        state.pendingStartedAt = nil
        return
    end

    state.pendingSpellId = nil
    state.pendingTargetGuid = nil
    state.pendingStartedAt = nil
    PrintCast(state, castState, targetGuid, spellId)
end

function card.RefreshRuntimeData()
end

function card.Execute(context)
    return false
end

Cat2.RegisterCard(card)
