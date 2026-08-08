-- 灵魂之火 技能卡片。
local card = {
    id = "warlock_soul_fire",
    name = "灵魂之火",
    description = "技能冷却后，施放灵魂之火",
    details = "技能冷却后，施放灵魂之火。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 40,
    category = "class",
    classes = {
        WARLOCK = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Fireball02",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 灵魂碎片保护
    if Cat2.GetItemByNameID("灵魂碎片") <= 0 then
        return false
    end

    if Cat2.SpellReadyOffset("灵魂之火") then
        CastSpellByName("灵魂之火")
        return true
    end

    return false

end

Cat2.RegisterCard(card)