-- 心灵震爆 技能卡片。
local card = {
    id = "priest_mind_blast",
    name = "心灵震爆",
    description = "冷却后，施放心灵震爆",
    details = "冷却后，施放心灵震爆。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 10,
    category = "class",
    classes = {
        PRIEST = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if Cat2.SpellReady("心灵震爆") then
        CastSpellByName("心灵震爆")
        return true
    end

    return false
end

Cat2.RegisterCard(card)