-- 顺劈斩 技能卡片。
local card = {
    id = "warrior_cleave",
    name = "顺劈斩",
    description = "怒气>50，施放顺劈斩",
    details = "怒气>50，施放顺劈斩。需要存在有效目标。会检查当前资源。",
    sort = 90,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_Cleave",
    },
}

local powerCleave = 20

function card.RefreshRuntimeData()
    powerCleave = 20 - Cat2.IsTalentLearned(2,11)
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
        Cat2.CastWithoutNampower("顺劈斩")
    end

end

Cat2.RegisterCard(card)