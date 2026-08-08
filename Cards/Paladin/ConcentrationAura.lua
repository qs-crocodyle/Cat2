-- 圣骑士神圣系：专注光环。
local card = {
    id = "paladin_concentration_aura",
    name = "专注光环",
    description = "切换并保持专注光环",
    details = "切换并保持专注光环。",
    sort = 0,
    category = "class",
    classes = {
        PALADIN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_MindSooth",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not Cat2.PlayerInformation.temporary.buff["专注光环"] then
        CastSpellByName("专注光环")
    end

end

Cat2.RegisterCard(card)
