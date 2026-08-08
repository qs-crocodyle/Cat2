-- 火舌武器 技能卡片。
local card = {
    id = "shaman_flametongue_weapon",
    name = "火舌武器",
    description = "对自己施放火舌武器",
    details = "对自己施放火舌武器。成功执行时会阻断本轮后续卡片。",
    sort = 20,
    exclusiveGroup = "shaman_weapon_enchant",
    category = "class",
    classes = {
        SHAMAN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_FlameTounge",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not string.find(Cat2.GetShamanEnchantName(),"火舌武器") then
        CastSpellByName("火舌武器")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
