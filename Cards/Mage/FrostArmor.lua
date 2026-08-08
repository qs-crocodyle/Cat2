-- 霜甲术 技能卡片。
local card = {
    id = "mage_frost_armor",
    name = "霜甲术",
    description = "切换并保持霜甲术",
    details = "切换并保持霜甲术。成功执行时会阻断本轮后续卡片。",
    sort = 60,
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

    if not Cat2.PlayerInformation.temporary.buff["霜甲术"] then
        CastSpellByName("霜甲术")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
