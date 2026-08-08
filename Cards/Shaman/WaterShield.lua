-- 水之护盾 技能卡片。
local card = {
    id = "shaman_water_shield",
    name = "水之护盾",
    description = "施放水之护盾，同时只能持续一个盾",
    details = "施放水之护盾，同时只能持续一个盾。",
    sort = 52,
    exclusiveGroup = "shaman_shield",
    category = "class",
    classes = {
        SHAMAN = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Shaman_WaterShield",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.buff["水之护盾"] then
        CastSpellByName("水之护盾")
        return
    end

    return false

end

Cat2.RegisterCard(card)
