-- 法力护盾 技能卡片。
local card = {
    id = "mage_mana_shield",
    name = "法力护盾",
    description = "法力护盾消失后，施放法力护盾",
    details = "法力护盾消失后，施放法力护盾。成功执行时会阻断本轮后续卡片。",
    sort = 80,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_DetectLesserInvisibility",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.buff["法力护盾"] then
        CastSpellByName("法力护盾")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
