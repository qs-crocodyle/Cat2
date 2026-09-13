-- 圣骑士防护系：火焰抗性光环。
local card = {
    id = "paladin_fire_resistance_aura",
    name = "火焰抗性光环",
    description = "切换并保持火焰抗性光环",
    details = "切换并保持火焰抗性光环。",
    sort = 63,
    category = "class",
    exclusiveGroup = "paladin_aura",
    classes = {
        PALADIN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_SealOfFire",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not Cat2.PlayerInformation.temporary.buff["火焰抗性光环"] then
        Cat2.Cast("火焰抗性光环")
    end

end

Cat2.RegisterCard(card)
