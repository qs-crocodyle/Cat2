-- 英勇打击 技能卡片。
local card = {
    id = "warrior_heroic_strike",
    name = "英勇打击",
    description = "怒气达到|cff6bc7e0{rageThreshold}|r时施放英勇打击",
    details = "怒气达到卡片设定值时施放英勇打击。需要存在有效目标。会检查当前资源。",
    sort = 85,
    exclusiveGroup = "warrior_heroic_strike_cleave",
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_Ambush",
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

local powerHeroice = 15

function card.RefreshRuntimeData()
    powerHeroice = 15 - Cat2.IsTalentLearned(1,1)
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end


    local rageThreshold = context:GetStepOption(step, "rageThreshold") or 50

    if player.power>=rageThreshold then
        Cat2.Cast("英勇打击")
    end

end

Cat2.RegisterCard(card)
