-- 鲁莽 技能卡片。
local card = {
    id = "warrior_recklessness",
    name = "鲁莽",
    description = "冷却好时，施放鲁莽",
    details = "冷却好时，施放鲁莽。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 180,
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

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    -- 不在近战范围
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

end

Cat2.RegisterCard(card)
