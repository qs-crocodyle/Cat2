-- 卡片注册中心：所有卡片文件在加载时向此处登记。
-- TOC 必须在所有卡片文件之前加载本文件；界面只从此中心读取可用卡片。
-- 本中心只保存“卡片定义”，不会保存玩家拖入流程后的 enabled 或 minimizedVisible 等运行时状态。
Cat2 = Cat2 or {}
-- 保存注册顺序的容器；Cards 中的每项是一个独立卡片定义表。
Cat2.CardRegistry = Cat2.CardRegistry or {}
Cat2.CardRegistry.Cards = Cat2.CardRegistry.Cards or {}
-- 按稳定 ID 保存卡片定义，供无需加入流程的直接调用使用。
Cat2.CardRegistry.ById = Cat2.CardRegistry.ById or {}

-- 运行时数据延迟到卡片第一次实际参与流程时再刷新。
-- 脏状态保存在注册中心的唯一卡片定义上，避免同一卡片在多个配置中重复刷新。
function Cat2.EnsureCardRuntimeData(card)
    if not card or card.runtimeDataDirty ~= true then
        return
    end
    if type(card.RefreshRuntimeData) == "function" then
        card.RefreshRuntimeData()
    end
    card.runtimeDataDirty = false
end

-- 标记单张卡片的运行时数据失效；只改状态，不在事件回调中执行耗时刷新。
function Cat2.MarkCardRuntimeDataDirty(cardId)
    local card = Cat2.CardRegistry.ById[cardId]
    if card and type(card.RefreshRuntimeData) == "function" then
        card.runtimeDataDirty = true
    end
end

-- 默认所有卡片都响应装备、技能和天赋变化。
-- 卡片可通过 runtimeDataRefreshTriggers 表只声明自己关心的类型。
function Cat2.MarkCardsRuntimeDataDirty(trigger)
    local cards = Cat2.CardRegistry.Cards
    local cardIndex = 1
    local cardTotal = table.getn(cards)
    while cardIndex <= cardTotal do
        local card = cards[cardIndex]
        if card and type(card.RefreshRuntimeData) == "function" then
            local triggers = card.runtimeDataRefreshTriggers
            if type(triggers) ~= "table" or triggers[trigger] == true then
                card.runtimeDataDirty = true
            end
        end
        cardIndex = cardIndex + 1
    end
end

-- 旧版客户端的装备、法术书与天赋变化事件只负责开启脏标记。
-- 下一次宏真正运行到卡片时，EnsureCardRuntimeData 才执行刷新。
local runtimeDataEventFrame = CreateFrame("Frame", "Cat2CardRuntimeDataEventFrame")
runtimeDataEventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
runtimeDataEventFrame:RegisterEvent("SPELLS_CHANGED")
runtimeDataEventFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
runtimeDataEventFrame:SetScript("OnEvent", function()
    if event == "UNIT_INVENTORY_CHANGED" then
        if arg1 == "player" then
            Cat2.MarkCardsRuntimeDataDirty("equipment")
        end
    elseif event == "SPELLS_CHANGED" then
        Cat2.MarkCardsRuntimeDataDirty("spells")
    elseif event == "CHARACTER_POINTS_CHANGED" then
        Cat2.MarkCardsRuntimeDataDirty("talents")
    end
end)

-- classes 统一保存“职业代码 = 天赋系序号”；单职业卡与共享卡使用同一种读取方式。
function Cat2.GetCardSpecializationForClass(card, classFile)
    if not card or type(card.classes) ~= "table" then
        return nil
    end
    local specialization = card.classes[classFile]
    if not specialization then
        return nil
    end

    -- 将卡片原始系别编号转换为界面显示页序；没有定制顺序的职业保持原编号。
    local order = Cat2.ClassSpecializationOrder and Cat2.ClassSpecializationOrder[classFile]
    if type(order) == "table" then
        local displayIndex = 1
        local displayTotal = table.getn(order)
        while displayIndex <= displayTotal do
            if order[displayIndex] == specialization then
                return displayIndex
            end
            displayIndex = displayIndex + 1
        end
    end

    return specialization
end

-- 流程槽始终以角色真实职业为门禁；预览其他职业时，仅共享卡仍可拖入。
function Cat2.CanAddCardForPlayer(card)
    if not card then
        return false
    end
    if card.category == "common" or card.category == "item" then
        return true
    end
    local actualClassFile = Cat2.PlayerInformation and Cat2.PlayerInformation.basic and Cat2.PlayerInformation.basic.classFile
    if not actualClassFile then
        local localizedClass, classFile = UnitClass("player")
        actualClassFile = classFile
    end
    return Cat2.GetCardSpecializationForClass(card, actualClassFile) ~= nil
end

-- 统一修改流程卡启用状态；开启互斥组成员时，自动暂停同流程中的其他成员。
function Cat2.SetFlowStepEnabled(steps, targetStep, enabled)
    if type(steps) ~= "table" or type(targetStep) ~= "table" then
        return
    end
    if enabled == 0 then
        targetStep.enabled = 0
        return
    end

    local exclusiveGroup = targetStep.exclusiveGroup
    if type(exclusiveGroup) == "string" and exclusiveGroup ~= "" then
        local stepIndex = 1
        local stepTotal = table.getn(steps)
        while stepIndex <= stepTotal do
            local step = steps[stepIndex]
            if step ~= targetStep and step.exclusiveGroup == exclusiveGroup then
                step.enabled = 0
            end
            stepIndex = stepIndex + 1
        end
    end
    targetStep.enabled = 1
end

-- 恢复或导入旧配置时统一互斥状态；同组多项开启时保留流程中最后一项。
function Cat2.NormalizeExclusiveFlowSteps(steps)
    if type(steps) ~= "table" then
        return
    end
    local activeByGroup = {}
    local stepIndex = 1
    local stepTotal = table.getn(steps)
    while stepIndex <= stepTotal do
        local step = steps[stepIndex]
        local exclusiveGroup = step and step.exclusiveGroup
        if step and step.enabled ~= 0 and type(exclusiveGroup) == "string" and exclusiveGroup ~= "" then
            local previousStep = activeByGroup[exclusiveGroup]
            if previousStep then
                previousStep.enabled = 0
            end
            activeByGroup[exclusiveGroup] = step
        end
        stepIndex = stepIndex + 1
    end
end

-- 所有图标统一保存在 icons 数组中，第一项始终是主图标。
function Cat2.GetCardPrimaryIcon(card)
    if not card or type(card.icons) ~= "table" then
        return "Interface\\Icons\\INV_Misc_QuestionMark"
    end
    return card.icons[1] or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- 卡片图标只使用卡片脚本内的 icons 定义。
-- 未确定的图标应在卡片中明确写为问号，不再根据角色技能书自动替换。
function Cat2.ResolveCardIcon(card)
    return Cat2.GetCardPrimaryIcon(card)
end

-- 注册单张卡片，并拒绝缺少核心字段或重复 ID 的定义。
function Cat2.RegisterCard(card)
    if not card or not card.id or not card.name or not card.category then
        return
    end
    if Cat2.CardRegistry.ById[card.id] then
        return
    end

    -- icons 同时保存主图标和辅助图标，最多保留三枚；第一枚用于快捷小窗。
    if type(card.icons) == "table" then
        local normalizedIcons = {}
        local iconIndex = 1
        local iconTotal = table.getn(card.icons)
        while iconIndex <= iconTotal and iconIndex <= 3 do
            if type(card.icons[iconIndex]) == "string" then
                table.insert(normalizedIcons, card.icons[iconIndex])
            end
            iconIndex = iconIndex + 1
        end
        card.icons = normalizedIcons
    else
        card.icons = { "Interface\\Icons\\INV_Misc_QuestionMark" }
    end
    if table.getn(card.icons) == 0 then
        card.icons[1] = "Interface\\Icons\\INV_Misc_QuestionMark"
    end

    -- 注册阶段只登记定义，不读取尚未就绪的装备、技能或天赋数据。
    card.runtimeDataDirty = true

    -- 被动卡片第一次参与流程时也要完成运行时数据刷新。
    local originalApply = card.Apply
    if type(originalApply) == "function" then
        card.Apply = function(context, step)
            Cat2.EnsureCardRuntimeData(card)
            return originalApply(context, step)
        end
    end

    local originalValidate = card.Validate
    if type(originalValidate) == "function" then
        card.Validate = function(context, step)
            Cat2.EnsureCardRuntimeData(card)
            return originalValidate(context, step)
        end
    end

    -- 对所有卡片统一 Execute 契约：只返回布尔值，true 表示流程到此终止。
    -- 旧卡片没有返回值或返回其他数据时统一视为 false，后续卡片继续执行。
    local originalExecute = card.Execute
    if type(originalExecute) == "function" then
        card.Execute = function(context)
            Cat2.EnsureCardRuntimeData(card)
            return originalExecute(context) == true
        end
    else
        card.Execute = function()
            return false
        end
    end

    table.insert(Cat2.CardRegistry.Cards, card)
    Cat2.CardRegistry.ById[card.id] = card
end

-- 直接执行注册中心里的普通卡片，不要求目标卡存在于当前流程。
-- 调用方仍需传入本轮 context；返回值遵循 true 阻断、false 继续的统一契约。
function Cat2.ExecuteCardById(cardId, context)
    if type(cardId) ~= "string" or cardId == "" or type(context) ~= "table" then
        return false
    end

    local targetCard = Cat2.CardRegistry.ById[cardId]
    if not targetCard or type(targetCard.Execute) ~= "function" then
        return false
    end

    -- 防止卡片直接或间接调用自身，造成无限递归。
    local executionGuard = context.directCardExecutionGuard
    if type(executionGuard) ~= "table" then
        executionGuard = {}
        context.directCardExecutionGuard = executionGuard
    end
    if executionGuard[cardId] then
        return false
    end

    executionGuard[cardId] = true
    local succeeded, result = pcall(targetCard.Execute, context)
    executionGuard[cardId] = nil

    if not succeeded then
        error(result)
    end

    return result == true
end

-- 根据职业文件代码返回右侧列表可见的卡片。
-- 通用和道具卡始终返回；职业卡统一检查 classes 中是否包含当前职业。
function Cat2.GetCardsForClass(classFile)
    local cards = {}
    local index = 1
    local total = table.getn(Cat2.CardRegistry.Cards)
    while index <= total do
        local card = Cat2.CardRegistry.Cards[index]
        local specialization = Cat2.GetCardSpecializationForClass(card, classFile)
        if card.category == "common" or card.category == "item" or specialization then
            Cat2.ResolveCardIcon(card)
            table.insert(cards, card)
        end
        index = index + 1
    end
    table.sort(cards, function(left, right)
        return left.sort < right.sort
    end)
    return cards
end
