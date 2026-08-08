local card = {
    id = "warlock_power_overwhelming",
    name = "超越之力",
    description = "强化当前召唤的恶魔",
    details = "强化当前召唤的恶魔。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 40,
    category = "class",
    classes = { WARLOCK = 2 },
    icons = { "Interface\\Icons\\Ability_Warlock_Power_Overwhelming" },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(2,14)
end

function card.Execute(context)
    if allowUse==0 then
        return false
    end

    if not UnitExists("pet") then
        return false
    end

    if Cat2.SpellReady("超越之力") then
        CastSpellByName("超越之力")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
