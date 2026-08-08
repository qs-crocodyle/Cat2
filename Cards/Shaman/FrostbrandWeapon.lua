-- 冰封武器 技能卡片。
local card = {
    id = "shaman_frostbrand_weapon",
    name = "冰封武器",
    description = "对自己施放冰封武器",
    details = "对自己施放冰封武器。成功执行时会阻断本轮后续卡片。",
    sort = 30,
    exclusiveGroup = "shaman_weapon_enchant",
    category = "class",
    classes = {
        SHAMAN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_FrostBrand",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not string.find(Cat2.GetShamanEnchantName(),"冰封武器") then
        CastSpellByName("冰封武器")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
