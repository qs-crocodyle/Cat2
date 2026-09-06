-- 断筋（触发乱舞）技能卡片；执行逻辑与原断筋卡保持一致。
local card = {
    id = "warrior_hamstring_flurry",
    name = "断筋（触发乱舞）",
    description = "未触发乱舞且怒气达到|cff6bc7e0{rageThreshold}|r时施放断筋",
    details = "未触发乱舞且怒气达到设定值时施放断筋，默认10怒气。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 140,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_ShockWave",
        "Interface\\Icons\\Ability_GhoulFrenzy",
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

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    -- 防御姿态下不执行。
    if Cat2.GetShapeByName("防御姿态") then
        return false
    end

    if player.power >= rageThreshold and not Cat2.WarriorFlurry() then
        Cat2.Cast("断筋")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
