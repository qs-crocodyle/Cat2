-- 圣骑士惩戒系：惩罚光环。
local card = {
    id = "paladin_punishment_aura",
    name = "惩罚光环",
    description = "切换并保持惩罚光环",
    details = "切换并保持惩罚光环。",
    sort = 0.5,
    category = "class",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_AuraOfLight",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not Cat2.PlayerInformation.temporary.buff["惩罚光环"] then
        Cat2.Cast("惩罚光环")
    end

end

Cat2.RegisterCard(card)
