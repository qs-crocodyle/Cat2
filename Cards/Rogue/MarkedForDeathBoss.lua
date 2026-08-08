-- 死亡标记强敌卡：仅在强敌目标条件下施放死亡标记。
local card = {
    id = "rogue_marked_for_death_boss",
    name = "死亡标记 仅强敌时",
    description = "强敌目标下，技能冷却后施放死亡标记",
    details = "强敌目标下，技能冷却后施放死亡标记。需要存在有效目标。会检查目标距离。会检查当前资源。仅在技能可用时尝试执行。",
    sort = 131,
    category = "class",
    classes = {
        ROGUE = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Creature_Cursed_02",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(3, 20)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists or not Cat2.IsBossTarget() then
        return false
    end


    if allowUse == 0 then
        return false
    end

    if player.power >= 40 and Cat2.SpellReady("死亡标记") and not player.buff["利用弱点"] and Cat2.TargetDistance() then
        CastSpellByName("死亡标记")
    end

    return false
end

Cat2.RegisterCard(card)
