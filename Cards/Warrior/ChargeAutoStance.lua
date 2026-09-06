-- 冲锋（自动姿态）技能卡片。
-- 复制冲锋的原有逻辑：自动切换战斗姿态后，非战斗状态在冲锋距离内施放。
local card = {
    id = "warrior_charge_auto_stance",
    name = "冲锋（自动姿态）",
    description = "怒气<=|cff6bc7e0{maximumRage}怒气|r时，自动切姿态施放冲锋",
    details = "当前怒气不高于卡片设定值时，自动切换至战斗姿态，并在未进入战斗且目标位于8-25码距离时施放冲锋。需要存在有效目标。会检查当前怒气和目标距离。成功执行时会阻断本轮后续卡片。",
    sort = 21,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_Charge",
        "Interface\\Icons\\Ability_Warrior_OffensiveStance",
    },
    cooldown = {
        type = "spell",
        name = "冲锋",
    },
    optionSchema = {
        {
            key = "maximumRage",
            type = "number",
            label = "怒气上限",
            shortLabel = "怒",
            unit = "怒气",
            default = 25,
            minimum = 0,
            maximum = 100,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local maximumRage = context:GetStepOption(step, "maximumRage") or 25

    -- 当前怒气高于设定上限时，避免自动切姿态造成怒气损失。
    if player.power > maximumRage then
        return false
    end

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    -- 战斗中不能冲锋。
    if player.inCombat then
        return false
    end

    if not Cat2.SpellReady("冲锋") then
        return false
    end

    -- 目标进入 8 码范围时不能冲锋。
    if Cat2.TargetDistance("target", 8) then
        return false
    end

    if not Cat2.GetShapeByName("战斗姿态") then
        Cat2.Cast("战斗姿态")
        return true
    end

    Cat2.Cast("冲锋")
    return true
end

Cat2.RegisterCard(card)
