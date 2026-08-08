-- 死亡之愿 技能卡片。
local card = {
    id = "warrior_death_wish",
    name = "死亡之愿",
    description = "冷却好时，施放死亡之愿",
    details = "冷却好时，施放死亡之愿。需要存在有效目标。会检查目标距离。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 170,
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

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    -- 不在近战范围
    if not Cat2.TargetDistance() then
        return false
    end

    if player.power>=10 and Cat2.SpellReady("死亡之愿") then
        Cat2.CastWithNampower("死亡之愿")
        return true
    end

end

Cat2.RegisterCard(card)