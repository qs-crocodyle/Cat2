-- 拳击（触发乱舞）：不用于打断，仅在乱舞未生效时尝试触发攻击暴击效果。
local card = {
    id = "warrior_pummel_flurry",
    name = "拳击（触发乱舞）",
    description = "未触发乱舞且怒气达到|cff6bc7e0{rageThreshold}|r时施放拳击",
    details = "不判断目标是否正在施法；仅在乱舞未生效、怒气达到设定值且拳击可用时施放，默认10怒气。需要存在有效目标，防御姿态下不执行。成功执行时会阻断本轮后续卡片。",
    -- 紧随原“拳击”卡片。
    sort = 151,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\INV_Gauntlets_04",
        "Interface\\Icons\\Ability_GhoulFrenzy",
    },
    cooldown = {
        type = "spell",
        name = "拳击",
    },
    optionSchema = {
        {
            key = "rageThreshold",
            type = "number",
            label = "使用怒气",
            shortLabel = "怒",
            default = 10,
            minimum = 10,
            maximum = 100,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local rageThreshold = context:GetStepOption(step, "rageThreshold") or 10

    if not player.targetExists then
        return false
    end

    if Cat2.GetShapeByName("防御姿态") then
        return false
    end

    if Cat2.WarriorFlurry() then
        return false
    end

    if player.power >= rageThreshold and Cat2.SpellReady("拳击") then
        Cat2.Cast("拳击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
