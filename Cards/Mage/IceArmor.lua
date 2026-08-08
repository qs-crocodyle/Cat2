-- 冰甲术 技能卡片。
local card = {
    id = "mage_ice_armor",
    name = "冰甲术",
    description = "切换并保持冰甲术",
    details = "切换并保持冰甲术。",
    sort = 50,
    exclusiveGroup = "mage_armor",
    category = "class",
    classes = {
        MAGE = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_FrostArmor02",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not Cat2.PlayerInformation.temporary.buff["冰甲术"] then
        CastSpellByName("冰甲术")
    end

    return false
end

Cat2.RegisterCard(card)
