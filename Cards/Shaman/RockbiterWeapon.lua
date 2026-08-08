-- 石化武器 技能卡片。
local card = {
    id = "shaman_rockbiter_weapon",
    name = "石化武器",
    description = "对自己施放石化武器",
    details = "对自己施放石化武器。成功执行时会阻断本轮后续卡片。",
    sort = 10,
    exclusiveGroup = "shaman_weapon_enchant",
    category = "class",
    classes = {
        SHAMAN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_RockBiter",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not string.find(Cat2.GetShamanEnchantName(),"石化武器") then
        CastSpellByName("石化武器")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
