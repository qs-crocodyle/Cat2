-- 防护火焰结界 技能卡片。
local card = {
    id = "mage_fire_ward",
    name = "防护火焰结界",
    description = "冷却后，施放防护火焰结界",
    details = "冷却后，施放防护火焰结界。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 70,
    category = "class",
    classes = {
        MAGE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_FireArmor",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if Cat2.SpellReady("防护火焰结界") then
        CastSpellByName("防护火焰结界")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
