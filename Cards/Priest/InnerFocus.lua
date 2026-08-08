-- 心灵专注技能卡片。
local card = {
    id = "priest_inner_focus",
    name = "心灵专注",
    description = "技能冷却后，施放心灵专注",
    details = "技能冷却后，施放心灵专注。仅在技能可用时尝试执行。",
    sort = 170,
    category = "class",
    classes = {
        PRIEST = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_WindWalkOn",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,9)
end

function card.Execute(context)

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end


    if Cat2.SpellReady("心灵专注") then
        CastSpellByName("心灵专注")
    end

    return false
end

Cat2.RegisterCard(card)
