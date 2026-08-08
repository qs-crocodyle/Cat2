-- 渐隐术 技能卡片。
local card = {
    id = "priest_fade",
    name = "渐隐术",
    description = "冷却后，施放渐隐术",
    details = "冷却后，施放渐隐术。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 90,
    category = "class",
    classes = {
        PRIEST = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Magic_LesserInvisibilty",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if Cat2.SpellReady("渐隐术") then
        CastSpellByName("渐隐术")
        return true
    end

    return false
end

Cat2.RegisterCard(card)