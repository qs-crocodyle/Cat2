-- 野性冲锋（自动形态）技能卡片。
-- 参照战士“冲锋（自动姿态）”：先切换熊形态，再在后续按键中施放；战斗内外均可执行。
local card = {
    id = "druid_feral_charge_auto_form",
    name = "野性冲锋（自动形态）",
    description = "自动切换熊形态，8码外施放野性冲锋",
    details = "目标位于8码外且野性冲锋可用时，自动切换至熊形态或巨熊形态，再施放野性冲锋。战斗内外均可执行。需要存在有效目标；熊形态下至少需要5点怒气。会检查技能、目标距离和当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 309,
    category = "class",
    classes = {
        DRUID = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Hunter_Pet_Bear",
        "Interface\\Icons\\Ability_Racial_BearForm",
    },
    cooldown = {
        type = "spell",
        name = "野性冲锋",
    },
}

local bearFormId = 0

function card.RefreshRuntimeData()
    bearFormId = 0
    local formCount = GetNumShapeshiftForms() or 0
    local formIndex = 1
    while formIndex <= formCount do
        local _, formName = GetShapeshiftFormInfo(formIndex)
        if formName == "巨熊形态" or formName == "熊形态" then
            bearFormId = formIndex
            return
        end
        formIndex = formIndex + 1
    end
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 未学习或正在冷却时不切换形态。
    if not Cat2.SpellReady("野性冲锋") then
        return false
    end

    -- 目标进入8码范围时不能施放野性冲锋。
    if Cat2.TargetDistance("target", 8) then
        return false
    end

    if bearFormId <= 0 then
        return false
    end

    if not Cat2.GetShape(bearFormId) then
        CastShapeshiftForm(bearFormId)
        return true
    end

    if player.power < 5 then
        return false
    end

    Cat2.Cast("野性冲锋")
    return true
end

Cat2.RegisterCard(card)
