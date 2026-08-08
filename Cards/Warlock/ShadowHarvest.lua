local card = {
    id = "warlock_shadow_harvest",
    name = "暗影收割",
    description = "技能冷却后，引导暗影收割",
    details = "技能冷却后，引导暗影收割。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 140,
    category = "class",
    classes = { WARLOCK = 1 },
    icons = { "Interface\\Icons\\Spell_Shadow_SoulLeech" },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,18)
end

function card.Execute(context)

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if Cat2.SpellReadyOffset("暗影收割",1.5) then
        CastSpellByName("暗影收割")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
