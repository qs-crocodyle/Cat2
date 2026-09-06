-- 查看玩家点燃：只显示 CatEvent-Mage 维护的当前每跳伤害数字。
local card = {
    id = "mage_view_my_ignite",
    name = "查看我的点燃",
    description = "显示点燃开始、结束、目标和当前每跳伤害",
    details = "通过Nampower结构化伤害与光环事件识别点燃归属，只显示属于玩家的点燃开始、结束、命中目标和当前每跳伤害，不显示预计总伤害或累计伤害。聊天窗口留空时沿用默认聊天框；填写窗口标签名后会尝试输出到对应聊天窗口，找不到时回退默认聊天框。仅在当前流程启用时生效。",
    sort = 999,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        MAGE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Incinerate",
    },
    events = {
        "CAT2_MAGE_IGNITE_CHANGED",
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

local function GetTargetText(targetGUID)
    local targetName
    if targetGUID and UnitExists(targetGUID) then
        targetName = UnitName(targetGUID)
    end
    if targetName and targetName ~= "" then
        return "|cffffb86b[" .. targetName .. "]|r"
    end
    return "|cffb8c7d9[" .. tostring(targetGUID or "未知目标") .. "]|r"
end

function card.OnEvent(state, eventName, payload)
    if eventName ~= "CAT2_MAGE_IGNITE_CHANGED" or type(payload) ~= "table" or type(payload.damage) ~= "number" then
        return
    end

    state.lastTargetGUID = payload.targetGUID
    state.lastDamage = payload.damage
    state.lastChangeType = payload.changeType
    state.lastChangeTime = GetTime()
    local targetText = GetTargetText(payload.targetGUID)
    local displayText
    if payload.changeType == "START" then
        displayText = "|cffff8a3d点燃开始|r → " .. targetText
            .. " |cffb8c7d9每跳 |r|cffffffff" .. tostring(payload.damage) .. "|r"
    elseif payload.changeType == "DAMAGE" then
        displayText = "|cffffd45a点燃|r → " .. targetText
            .. " |cffb8c7d9每跳 |r|cffffffff" .. tostring(payload.damage) .. "|r"
    elseif payload.changeType == "END" then
        displayText = "|cff9aa5b1点燃结束|r → " .. targetText
    else
        return
    end
    PrintToConfiguredChatFrame(
        state,
        "|cff66ccffCat2：|r" .. displayText
    )
end

function card.RefreshRuntimeData()
end

function card.Execute(context)
    return false
end

Cat2.RegisterCard(card)
