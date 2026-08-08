-- 魔甲术 技能卡片。
local card = {
    id = "mage_mage_armor",
    name = "魔甲术",
    description = "切换并保持魔甲术",
    details = "切换并保持魔甲术。",
    sort = 70,
    exclusiveGroup = "mage_armor",
    category = "class",
    classes = {
        MAGE = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_MageArmor",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not Cat2.PlayerInformation.temporary.buff["魔甲术"] then
        CastSpellByName("魔甲术")
    end

    return false
end

Cat2.RegisterCard(card)
