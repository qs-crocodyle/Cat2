local card = {
    id = "warlock_curse_of_doom",
    name = "厄运诅咒",
    description = "技能冷却后，施放厄运诅咒",
    details = "技能冷却后，施放厄运诅咒。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 60,
    exclusiveGroup = "warlock_major_curse",
    category = "class",
    classes = { WARLOCK = 1 },
    icons = { "Interface\\Icons\\Spell_Shadow_AuraOfDarkness" },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    local onlyBoss = context and context.parameters and context.parameters.warlockMajorCurseOnlyBoss
    if onlyBoss and not Cat2.IsBossTarget() then
        return false
    end

    if not player.targetBuff["厄运诅咒"] and Cat2.SpellReady("厄运诅咒") then
        CastSpellByName("厄运诅咒")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
