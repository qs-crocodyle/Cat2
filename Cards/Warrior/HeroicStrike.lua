-- 英勇打击 技能卡片。
local card = {
    id = "warrior_heroic_strike",
    name = "英勇打击",
    description = "怒气>50，施放英勇打击",
    details = "怒气>50，施放英勇打击。需要存在有效目标。会检查当前资源。",
    sort = 85,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_Ambush",
    },
}

local powerHeroice = 15

function card.RefreshRuntimeData()
    powerHeroice = 15 - Cat2.IsTalentLearned(1,1)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end


    local rageThreshold = context.parameters.warriorRageThreshold
    -- 队列中没有启用怒气阈值被动卡时，使用默认值
    if rageThreshold == nil then
        rageThreshold = 50
    end

    if player.power>=rageThreshold then
        Cat2.CastWithoutNampower("英勇打击")
    end

end

Cat2.RegisterCard(card)
