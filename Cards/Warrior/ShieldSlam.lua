-- 盾牌猛击 技能卡片。
local card = {
    id = "warrior_shield_slam",
    name = "盾牌猛击",
    description = "冷却好时，施放盾牌猛击",
    details = "冷却好时，施放盾牌猛击。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 100,
    category = "class",
    classes = {
        WARRIOR = 3,
    },
    icons = {
        "Interface\\Icons\\INV_Shield_05",
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

    -- 必须有盾牌
    if not Cat2.IsOffHandShield() then
        return false
    end

    if player.power>=20 and Cat2.SpellReady("盾牌猛击") then
        CastSpellByName("盾牌猛击")
        return true
    end

end

Cat2.RegisterCard(card)