-- 痛苦诅咒（多线DOT）技能卡片。
local card = {
    id = "warlock_curse_of_agony_multi_dot",
    name = "痛苦诅咒（多线DOT）",
    description = "为附近没有痛苦诅咒的敌人施放痛苦诅咒",
    details = "扫描痛苦诅咒射程内的敌人，并对其中没有痛苦诅咒且不免疫暗影伤害的目标无目标施放痛苦诅咒。需要 SuperWoW；每轮最多选择一个敌人施放。",
    sort = 155,
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",
        "Interface\\Icons\\Spell_Fire_Flare",
    },
}

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("痛苦诅咒", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 30
    end

    local CurseAgonyDuration = 24
    CurseAgonyDuration = tonumber(Cat2.Match(Cat2.GetSpellTooltip("痛苦诅咒", "等级 5"), "使其在(%d+%.%d+)"))
    if not CurseAgonyDuration then
        CurseAgonyDuration = 24
    end
    Cat2.SetCurseAgonyDuration(CurseAgonyDuration)
end

function card.Execute(context)
    if not Cat2.SuperWoW then
        return false
    end

    -- 无目标施法入口会直接调用 CastSpellByName，因此在这里补齐普通 Cat2.Cast 的引导保护。
    if Cat2.GetChanneled() >= 0.08 then
        return false
    end

    local count, _, enemyList = Cat2.ScanNearbyEnemies(distance)
    if count <= 0 then
        return false
    end

    local requireCombatTarget = context and context.parameters and context.parameters.warlockMultiDotOnlyCombatEnemies
    for guid, _ in pairs(enemyList) do
        if UnitExists(guid) and UnitCanAttack("player", guid) and not UnitIsDeadOrGhost(guid)
            and (not requireCombatTarget or UnitAffectingCombat(guid)) then
            local hasCurseOfAgony = Cat2.Buff("痛苦诅咒", guid)
            if not hasCurseOfAgony and not Cat2.IsShadowImmune(guid) then
                if Cat2.CastSpellWithoutTarget("痛苦诅咒", guid) then
                    return true
                end
            end
        end
    end

    return false
end

Cat2.RegisterCard(card)
