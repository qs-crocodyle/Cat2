-- 惩击 技能卡片。
local card = {
    id = "priest_smite",
    name = "惩击",
    description = "施放惩击，适合做填充技能",
    details = "施放惩击，适合做填充技能。",
    sort = 40,
    category = "class",
    classes = {
        PRIEST = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_HolySmite",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    CastSpellByName("惩击")
    return false
end

Cat2.RegisterCard(card)
