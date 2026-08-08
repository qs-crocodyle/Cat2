-- 英勇打击复制卡；执行逻辑与原英勇打击卡保持一致。
local card = {
    id = "warrior_heroic_strike_alt",
    name = "自动 英勇打击/顺劈斩",
    description = "怒气>50，周围敌人数自动施放英勇打击/顺劈斩",
    details = "怒气>50，周围敌人数自动施放英勇打击/顺劈斩。需要存在有效目标。会检查当前资源。",
    sort = 92,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_Ambush",
        "Interface\\Icons\\Ability_Warrior_Cleave",
    },
}

local powerHeroice = 15

function card.RefreshRuntimeData()
    powerHeroice = 15 - Cat2.IsTalentLearned(1, 1)
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end


    local nearby = Cat2.ScanNearbyEnemies(7)

    local rageThreshold = context.parameters.warriorRageThreshold
    -- 队列中没有启用怒气阈值被动卡时，使用默认值
    if rageThreshold == nil then
        rageThreshold = 50
    end

    if player.power >= rageThreshold then
        if nearby>1 then
            Cat2.CastWithoutNampower("顺劈斩")
        else
            Cat2.CastWithoutNampower("英勇打击")
        end
    end
end

Cat2.RegisterCard(card)
