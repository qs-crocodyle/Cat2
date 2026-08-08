-- 鲁莽强敌卡：仅在强敌目标条件下执行原鲁莽规则。
local card = {
    id = "warrior_recklessness_boss",
    name = "鲁莽 仅强敌时",
    description = "强敌目标下，冷却好时施放鲁莽",
    details = "强敌目标下，冷却好时施放鲁莽。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 185,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_CriticalStrike",
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

    if not Cat2.SetShape("狂暴姿态") then
        return false
    end

    if Cat2.SpellReady("鲁莽") then
        Cat2.CastWithNampower("鲁莽")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
