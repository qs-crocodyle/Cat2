-- 圣骑士防护系：暗影抗性光环。
local card = {
    id = "paladin_shadow_resistance_aura",
    name = "暗影抗性光环",
    description = "切换并保持暗影抗性光环",
    details = "切换并保持暗影抗性光环。",
    sort = 61,
    category = "class",
    exclusiveGroup = "paladin_aura",
    classes = {
        PALADIN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_SealOfKings",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not Cat2.PlayerInformation.temporary.buff["暗影抗性光环"] then
        Cat2.Cast("暗影抗性光环")
    end

end

Cat2.RegisterCard(card)
