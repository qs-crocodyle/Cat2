-- 邪恶攻击 技能卡片。
local card = {
    id = "rogue_sinister_strike",
    name = "邪恶攻击",
    description = "40能量时施放邪恶攻击",
    details = "40能量时施放邪恶攻击。需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 20,
    category = "class",
    canStopSequence = true,
    classes = {
        ROGUE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if player.power >= 40 then
        CastSpellByName("邪恶攻击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
