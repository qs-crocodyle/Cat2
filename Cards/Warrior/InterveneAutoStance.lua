-- 援护（自动姿态）技能卡片。
-- 自动切换防御姿态后，对距离合适的友方目标施放援护。
local card = {
    id = "warrior_intervene_auto_stance",
    name = "援护（自动姿态）",
    description = "怒气<=|cff6bc7e0{maximumRage}怒气|r时，自动切姿态施放援护",
    details = "当前怒气不少于10点且不高于卡片设定值时，自动切换至防御姿态，并对位于8-25码距离的友方目标施放援护。需要存在有效友方目标。会检查当前怒气和目标距离。成功执行时会阻断本轮后续卡片。",
    sort = 15,
    category = "class",
    classes = {
        WARRIOR = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_Intervene",
        "Interface\\Icons\\Ability_Warrior_DefensiveStance",
    },
    optionSchema = {
        {
            key = "maximumRage",
            type = "number",
            label = "怒气上限",
            shortLabel = "怒",
            unit = "怒气",
            default = 100,
            minimum = 10,
            maximum = 100,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local maximumRage = context:GetStepOption(step, "maximumRage") or 100

    -- 援护至少需要 10 点怒气，同时不能超过用户设定的怒气上限。
    if player.power < 10 or player.power > maximumRage then
        return false
    end

    -- 援护只能以存活的友方单位为目标。
    if not player.targetExists or player.targetCanAttack or UnitIsDeadOrGhost("target") then
        return false
    end

    if not Cat2.SpellReady("援护") then
        return false
    end

    -- 目标进入 8 码范围时无需援护。
    if Cat2.TargetDistance("target", 8) then
        return false
    end

    if not Cat2.GetShapeByName("防御姿态") then
        Cat2.Cast("防御姿态")
        return true
    end

    Cat2.Cast("援护")
    return true
end

Cat2.RegisterCard(card)
