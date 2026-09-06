-- 圣骑士防护系：冰霜抗性光环。
local card = {
    id = "paladin_frost_resistance_aura",
    name = "冰霜抗性光环",
    description = "切换并保持冰霜抗性光环",
    details = "切换并保持冰霜抗性光环。",
    sort = 62,
    category = "class",
    classes = {
        PALADIN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_WizardMark",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not Cat2.PlayerInformation.temporary.buff["冰霜抗性光环"] then
        Cat2.Cast("冰霜抗性光环")
    end

end

Cat2.RegisterCard(card)
