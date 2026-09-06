-- 猎人印记仅在强敌目标上保持的技能卡片。
local card = {
    id = "hunter_hunters_mark_boss",
    name = "猎人印记 仅强敌时",
    description = "仅对强敌目标施放并保持猎人印记",
    details = "仅对强敌目标施放并保持猎人印记。需要存在有效目标；目标奥术免疫时不会施放。成功执行时会阻断本轮后续卡片。",
    sort = 21,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Hunter_SniperShot",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists or not Cat2.IsBossTarget() then
        return false
    end

    -- 目标奥术免疫时，不再尝试施放猎人印记。
    if Cat2.IsArcaneImmune() then
        return false
    end

    if not player.targetBuff["猎人印记"] then
        Cat2.Cast("猎人印记")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
