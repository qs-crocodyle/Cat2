-- 急速射击仅在强敌阶段使用的技能卡片。
local card = {
    id = "hunter_rapid_fire_boss",
    name = "急速射击 仅强敌时",
    description = "强敌阶段技能冷却后，施放急速射击",
    details = "强敌阶段技能冷却后，施放急速射击。需要存在有效目标。会检查战斗状态。仅在技能可用时尝试执行。",
    sort = 121,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Hunter_RunningShot",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists or not Cat2.IsBossTarget() then
        return false
    end


    if Cat2.SpellReady("急速射击") and player.inCombat then
        CastSpellByName("急速射击")
    end

    return false
end

Cat2.RegisterCard(card)
