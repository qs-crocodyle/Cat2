-- 圣骑士惩戒系：圣洁光环。
local card = {
    id = "paladin_sanctity_aura",
    name = "圣洁光环",
    description = "切换并保持圣洁光环",
    details = "切换并保持圣洁光环。",
    sort = 0,
    category = "class",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_MindVision",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not Cat2.PlayerInformation.temporary.buff["圣洁光环"] then
        CastSpellByName("圣洁光环")
    end

end

Cat2.RegisterCard(card)
