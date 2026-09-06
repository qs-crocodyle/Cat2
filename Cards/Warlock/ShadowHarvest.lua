local card = {
    id = "warlock_shadow_harvest",
    name = "暗影收割",
    description = "技能冷却后，引导暗影收割",
    details = "技能冷却后，引导暗影收割。需要存在有效目标；目标暗影免疫时不会施放。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 140,
    category = "class",
    classes = { WARLOCK = 1 },
    icons = { "Interface\\Icons\\Spell_Shadow_SoulLeech" },
    cooldown = { type = "spell", name = "暗影收割" },
}

local allowUse = 0
local distance = 30

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,18)
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("暗影收割", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 30
    end
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

    -- 目标暗影免疫时，不再尝试施放暗影伤害技能。
    if Cat2.IsShadowImmune() then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    if Cat2.SpellReadyOffset("暗影收割",1.5) then
        Cat2.CastWarlockWithDrainInterrupt(context, "warlockShadowHarvestInterruptChannel", "暗影收割")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
