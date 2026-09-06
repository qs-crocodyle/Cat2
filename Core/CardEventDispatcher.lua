-- 卡片事件分发中心。
-- 所有卡片共用一个事件 Frame；卡片只声明需要的事件并在自己的文件中处理状态。
-- 游戏事件与 Cat2 内部事件共用订阅、启用门禁及 pcall 错误隔离，但内部事件不会注册到客户端。
-- eventStatesByCardId 是本次会话的临时状态，切换配置不会复制，重载界面后自然清空。
-- 事件处理器不得施放技能或执行其他受保护操作；需要按键授权的动作应只记录请求供流程读取。
Cat2 = Cat2 or {}

local eventFrame = CreateFrame("Frame", "Cat2CardEventDispatcherFrame")
local subscribersByEvent = {}
local registeredEvents = {}
local eventStatesByCardId = {}
local reportedHandlerErrors = {}
local internalEvents = {
    -- CastInterruptMonitor 在按键链真正提交停法时发送，查看施法卡片据此显示可解释原因。
    CAT2_CAST_INTERRUPTED = true,
    -- CatEvent-Mage 通过 Nampower 维护属于玩家的点燃归属与每跳伤害。
    CAT2_MAGE_IGNITE_CHANGED = true,
}

local function CardSupportsCurrentPlayer(card)
    if not card then
        return false
    end
    if card.category == "common" or card.category == "item" then
        return true
    end

    local classFile = Cat2.PlayerInformation
        and Cat2.PlayerInformation.basic
        and Cat2.PlayerInformation.basic.classFile
    if not classFile then
        local localizedClass
        localizedClass, classFile = UnitClass("player")
    end
    return Cat2.GetCardSpecializationForClass(card, classFile) ~= nil
end

local function GetOrCreateEventState(cardId)
    local state = eventStatesByCardId[cardId]
    if type(state) ~= "table" then
        state = {}
        eventStatesByCardId[cardId] = state
    end
    return state
end

-- 事件只分发给当前配置流程中至少存在一个已启用步骤的卡片。
-- 每次事件只扫描一次当前流程，避免为每个事件订阅者重复遍历卡槽。
local function BuildActiveFlowCardLookup()
    local activeCardLookup = {}
    local repository = Cat2.RuntimeConfigurations
    if type(repository) ~= "table" or type(repository.profiles) ~= "table" then
        return activeCardLookup
    end

    local profile = repository.profiles[repository.activeProfileId]
    if type(profile) ~= "table" or type(profile.steps) ~= "table" then
        return activeCardLookup
    end

    local stepIndex = 1
    local stepTotal = table.getn(profile.steps)
    while stepIndex <= stepTotal do
        local step = profile.steps[stepIndex]
        if step and step.enabled ~= 0 and type(step.id) == "string" then
            -- 事件卡可以从临时状态读取当前流程步骤，从而解析自己的卡片参数。
            -- unique 事件卡只会有一个步骤；非 unique 卡保留流程中的第一个启用步骤。
            if activeCardLookup[step.id] == nil then
                activeCardLookup[step.id] = step
            end
        end
        stepIndex = stepIndex + 1
    end
    return activeCardLookup
end

-- 读取指定卡片的临时事件状态；状态只存在于本次游戏会话中。
function Cat2.GetCardEventState(cardId)
    if type(cardId) ~= "string" or cardId == "" then
        return nil
    end
    if not Cat2.CardRegistry or not Cat2.CardRegistry.ById[cardId] then
        return nil
    end
    return GetOrCreateEventState(cardId)
end

function Cat2.ResetCardEventState(cardId)
    if type(cardId) ~= "string" or cardId == "" then
        return false
    end
    if not Cat2.CardRegistry or not Cat2.CardRegistry.ById[cardId] then
        return false
    end
    eventStatesByCardId[cardId] = {}
    return true
end

function Cat2.ResetAllCardEventStates()
    eventStatesByCardId = {}
end

local function DispatchToActiveCards(
    eventName,
    value1,
    value2,
    value3,
    value4,
    value5,
    value6,
    value7,
    value8,
    value9,
    value10,
    value11,
    value12
)
    local subscribers = subscribersByEvent[eventName]
    if type(subscribers) ~= "table" then
        return false
    end

    local activeCardLookup = BuildActiveFlowCardLookup()
    local dispatched = false
    for cardId, card in pairs(subscribers) do
        local activeStep = activeCardLookup[cardId]
        if activeStep then
            local state = GetOrCreateEventState(cardId)
            state.activeStep = activeStep
            local succeeded, errorMessage = pcall(
                card.OnEvent,
                state,
                eventName,
                value1,
                value2,
                value3,
                value4,
                value5,
                value6,
                value7,
                value8,
                value9,
                value10,
                value11,
                value12
            )
            if not succeeded then
                local errorKey = cardId .. "|" .. eventName
                if not reportedHandlerErrors[errorKey] then
                    reportedHandlerErrors[errorKey] = true
                    DEFAULT_CHAT_FRAME:AddMessage(
                        "|cffff5555Cat2：卡片事件处理失败「" .. (card.name or cardId) .. "」：|r" .. tostring(errorMessage)
                    )
                end
            else
                dispatched = true
            end
        end
    end
    return dispatched
end

-- Cat2 内部事件不向游戏客户端注册，只复用卡片事件的启用状态与错误隔离机制。
function Cat2.DispatchCardInternalEvent(eventName, payload)
    if internalEvents[eventName] ~= true then
        return false
    end
    return DispatchToActiveCards(eventName, payload)
end

-- 卡片格式：events = { "EVENT_NAME" }，并实现 card.OnEvent(state, eventName, ...)。
-- 注册阶段只建立索引，不创建卡片专属 Frame，也不执行任何卡片逻辑。
function Cat2.RegisterCardEvents(card)
    if not card or type(card.id) ~= "string" then
        return false
    end
    if type(card.events) ~= "table" or type(card.OnEvent) ~= "function" then
        return false
    end
    if not CardSupportsCurrentPlayer(card) then
        return false
    end

    local eventIndex = 1
    local eventTotal = table.getn(card.events)
    local subscribed = false
    while eventIndex <= eventTotal do
        local eventName = card.events[eventIndex]
        if type(eventName) == "string" and eventName ~= "" then
            if not registeredEvents[eventName] then
                if internalEvents[eventName] then
                    registeredEvents[eventName] = true
                else
                    local succeeded = pcall(eventFrame.RegisterEvent, eventFrame, eventName)
                    if succeeded then
                        registeredEvents[eventName] = true
                    end
                end
            end
            if registeredEvents[eventName] then
                local subscribers = subscribersByEvent[eventName]
                if type(subscribers) ~= "table" then
                    subscribers = {}
                    subscribersByEvent[eventName] = subscribers
                end
                subscribers[card.id] = card
                subscribed = true
            end
        end
        eventIndex = eventIndex + 1
    end
    return subscribed
end

eventFrame:SetScript("OnEvent", function()
    DispatchToActiveCards(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
end)
