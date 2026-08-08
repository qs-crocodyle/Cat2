-- 特效打击 技能卡片。
local card = {
    id = "warrior_special_strike",
    name = "特效打击",
    description = "冷却好时，施放特效打击",
    details = "冷却好时，施放特效打击。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 120,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\master_strike_1",
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

    if player.power>=20 and Cat2.SpellReady("特效打击") then
        CastSpellByName("特效打击")
        return true
    end

end

Cat2.RegisterCard(card)
