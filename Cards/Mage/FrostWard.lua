-- 防护冰霜结界 技能卡片。
local card = {
    id = "mage_frost_ward",
    name = "防护冰霜结界",
    description = "冷却后，施放防护冰霜结界",
    details = "冷却后，施放防护冰霜结界。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 80,
    category = "class",
    classes = {
        MAGE = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_FrostWard",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if Cat2.SpellReady("防护冰霜结界") then
        CastSpellByName("防护冰霜结界")
        return true
    end

    return false

end

Cat2.RegisterCard(card)