-- 恶魔支配技能卡片。
local card = {
    id = "warlock_fel_domination",
    name = "恶魔支配",
    description = "技能冷却后，施放恶魔支配",
    details = "技能冷却后，施放恶魔支配。仅在技能可用时尝试执行。",
    sort = 50,
    category = "class",
    classes = { WARLOCK = 2 },
    icons = { "Interface\\Icons\\Spell_Nature_RemoveCurse" },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(2,7)
end

function card.Execute(context)
    if allowUse==0 then
        return false
    end

    if not UnitExists("pet") then
        return false
    end

    if Cat2.SpellReady("恶魔支配") then
        CastSpellByName("恶魔支配")
    end

    return false
end

Cat2.RegisterCard(card)
