-- 佯攻技能卡片；冷却完成且能量足够时施放。
local card = {
    id = "rogue_feint",
    name = "佯攻",
    description = "冷却完成且能量足够时施放佯攻",
    details = "存在有效目标时，佯攻冷却完成且能量不少于20时施放。会检查当前资源和技能冷却。成功执行时会阻断本轮后续卡片。",
    sort = 92,
    category = "class",
    canStopSequence = true,
    classes = {
        ROGUE = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_Feint",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if player.power>=20 and Cat2.SpellReady("佯攻") then
        CastSpellByName("佯攻")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
