-- 死亡之愿强敌卡：仅在强敌目标条件下执行原死亡之愿规则。
local card = {
    id = "warrior_death_wish_boss",
    name = "死亡之愿 仅强敌时",
    description = "强敌目标下，冷却好时施放死亡之愿",
    details = "强敌目标下，冷却好时施放死亡之愿。需要存在有效目标。会检查目标距离。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 175,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_DeathPact",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists or not Cat2.IsBossTarget() then
        return false
    end

    if not Cat2.TargetDistance() then
        return false
    end

    if player.power >= 10 and Cat2.SpellReady("死亡之愿") then
        Cat2.CastWithNampower("死亡之愿")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
