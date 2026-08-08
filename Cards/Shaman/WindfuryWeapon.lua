-- 风怒武器 技能卡片。
local card = {
    id = "shaman_windfury_weapon",
    name = "风怒武器",
    description = "对自己施放风怒武器",
    details = "对自己施放风怒武器。成功执行时会阻断本轮后续卡片。",
    sort = 40,
    exclusiveGroup = "shaman_weapon_enchant",
    category = "class",
    classes = {
        SHAMAN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_Cyclone",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not string.find(Cat2.GetShamanEnchantName(),"风怒武器") then
        CastSpellByName("风怒武器")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
