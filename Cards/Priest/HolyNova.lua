-- 神圣新星 技能卡片。
local card = {
    id = "priest_holy_nova",
    name = "神圣新星",
    description = "周围有>3个敌人时，施放神圣新星，需UnitXP模组",
    details = "周围有>3个敌人时，施放神圣新星，需UnitXP模组。成功执行时会阻断本轮后续卡片。",
    sort = 70,
    category = "class",
    classes = {
        PRIEST = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_HolyNova",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary
    local nearby = Cat2.ScanNearbyEnemies(8)

    if nearby>=3 then
        CastSpellByName("神圣新星")
        return true
    end

    return false

end

Cat2.RegisterCard(card)