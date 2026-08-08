-- 圣骑士防护系：虔诚光环。
local card = {
    id = "paladin_devotion_aura",
    name = "虔诚光环",
    description = "切换并保持虔诚光环",
    details = "切换并保持虔诚光环。",
    sort = 60,
    category = "class",
    classes = {
        PALADIN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_DevotionAura",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not Cat2.PlayerInformation.temporary.buff["虔诚光环"] then
        CastSpellByName("虔诚光环")
    end

end

Cat2.RegisterCard(card)
