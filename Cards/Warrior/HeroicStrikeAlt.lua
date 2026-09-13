-- 英勇打击复制卡；执行逻辑与原英勇打击卡保持一致。
local card = {
    id = "warrior_heroic_strike_alt",
    name = "自动 英勇打击/顺劈斩",
    description = "怒气达到|cff6bc7e0{rageThreshold}|r，至少2个敌人时顺劈",
    details = "怒气达到卡片设定值时，周围至少2个敌人则施放顺劈斩，否则施放英勇打击。需要存在有效目标。会检查当前资源。",
    sort = 92,
    exclusiveGroup = "warrior_heroic_strike_cleave",
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_Ambush",
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

local powerHeroice = 15

function card.RefreshRuntimeData()
    powerHeroice = 15 - Cat2.IsTalentLearned(1, 1)
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end


    -- 被动开启时只统计正面敌人，否则保持原来的附近敌人数。
    local nearby = Cat2.GetEligibleCleaveEnemyCount(context, 7)

    local rageThreshold = context:GetStepOption(step, "rageThreshold") or 50

    if player.power >= rageThreshold then
        if nearby>=2 then
            Cat2.Cast("顺劈斩")
        else
            -- 顺劈条件不足时继续使用英勇打击。
            Cat2.Cast("英勇打击")
        end
    end
end

Cat2.RegisterCard(card)
