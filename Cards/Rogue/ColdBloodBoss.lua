-- 冷血强敌卡：仅在强敌目标条件下施放冷血。
local card = {
    id = "rogue_cold_blood_boss",
    name = "冷血 仅强敌时",
    description = "强敌目标下，技能冷却后施放冷血",
    details = "强敌目标下，技能冷却后施放冷血。需要存在有效目标。会检查目标距离。会检查战斗状态。",
    sort = 2,
    category = "class",
    classes = {
        ROGUE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Ice_Lament",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1, 15)
end

function card.Execute(context)

    if not Cat2.IsBossTarget() then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists or not player.inCombat then
        return false
    end


    if allowUse == 0 then
        return false
    end

    if Cat2.RogueColdBloodReady() and Cat2.TargetDistance() then
        CastSpellByName("冷血")
    end

    return false
end

Cat2.RegisterCard(card)
