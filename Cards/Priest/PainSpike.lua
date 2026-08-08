-- 痛苦尖刺技能卡片。
local card = {
    id = "priest_pain_spike",
    name = "痛苦尖刺",
    description = "冷却后，对目标施放痛苦尖刺",
    details = "冷却后，对目标施放痛苦尖刺。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 11,
    category = "class",
    classes = {
        PRIEST = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_PainSpike",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if Cat2.SpellReady("痛苦尖刺") then
        CastSpellByName("痛苦尖刺")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
