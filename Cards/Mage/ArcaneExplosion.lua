-- 魔爆术 技能卡片。
local card = {
    id = "mage_arcane_explosion",
    name = "魔爆术",
    description = "周围有>3个敌人时，施放魔爆术，需UnitXP模组",
    details = "周围有>3个敌人时，施放魔爆术，需UnitXP模组。成功执行时会阻断本轮后续卡片。",
    sort = 40,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_WispSplode",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary
    local nearby = Cat2.ScanNearbyEnemies(8)

    if nearby>=3 then
        CastSpellByName("魔爆术")
        return true
    end

    return false

end

Cat2.RegisterCard(card)