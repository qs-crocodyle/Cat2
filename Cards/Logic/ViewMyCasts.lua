-- 事件型被动卡参考：events 只声明订阅，OnEvent 仅在本卡位于当前流程且已启用时执行。
-- 本卡过滤被动与触发效果；需要完整原始事件时使用 ViewMyCastsDetailed.lua。
local card = {
    id = "common_view_my_casts",
    name = "查看我的施法",
    description = "成功施法后，在聊天框打印技能名和等级",
    details = "监听玩家主动施放的技能，并将技能名和等级打印到聊天框。聊天窗口留空时沿用默认聊天框；填写窗口标签名后会尝试输出到对应聊天窗口，找不到时回退默认聊天框。会过滤技能书被动技能及多数触发特效，仅在当前流程启用时生效。",
    sort = 910,
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

-- 普通查看卡只保留玩家技能书中的主动技能；详细卡负责显示完整事件。
local function IsPlayerActiveSpell(spellId)
    local spellName, spellRank = GetSpellNameAndRank(spellId)
    if not spellName then
        return false
    end

    local spellIndex = Cat2.GetSpellID(spellName, spellRank)
    if not spellIndex or spellIndex == 0 then
        spellIndex = Cat2.GetSpellID(spellName)
    end
    if not spellIndex or spellIndex == 0 then
        return false
    end

    if type(IsPassiveSpell) == "function" then
        local bookType = BOOKTYPE_SPELL or "spell"
        local succeeded, isPassive = pcall(IsPassiveSpell, spellIndex, bookType)
        if succeeded and isPassive then
            return false
        end
    end
    return true
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
    if not IsPlayerActiveSpell(spellId) then
        return
    end

    if castState == "START" or castState == "CHANNEL" then
        -- 读条和引导在启动时立即打印；记住本次施法，完成事件不再重复输出。
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
