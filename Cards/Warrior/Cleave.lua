-- 顺劈斩 技能卡片。
local card = {
    id = "warrior_cleave",
    name = "顺劈斩",
    description = "怒气达到|cff6bc7e0{rageThreshold}|r时施放顺劈斩",
    details = "怒气达到卡片设定值时施放顺劈斩。需要存在有效目标。会检查当前资源。",
    sort = 90,
    exclusiveGroup = "warrior_heroic_strike_cleave",
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_Cleave",
    },
    optionSchema = {
        {
            key = "rageThreshold",
            type = "number",
            label = "怒气阈值",
            shortLabel = "怒",
            default = 50,
            minimum = 1,
            maximum = 100,
        },
    },
}

local powerCleave = 20

function card.RefreshRuntimeData()
    powerCleave = 20 - Cat2.IsTalentLearned(2,11)
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end


    local rageThreshold = context:GetStepOption(step, "rageThreshold") or 50

    if player.power>=rageThreshold then
        Cat2.Cast("顺劈斩")
    end

end

Cat2.RegisterCard(card)
