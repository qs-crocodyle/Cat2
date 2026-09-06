-- 腐蚀术（多线DOT）技能卡片。
local card = {
    id = "warlock_corruption_multi_dot",
    name = "腐蚀术（多线DOT）",
    description = "为附近没有腐蚀术的敌人施放腐蚀术",
    details = "扫描腐蚀术射程内的敌人，并对其中没有腐蚀术且不免疫暗影伤害的目标无目标施放腐蚀术。需要 SuperWoW；每轮最多选择一个敌人施放。",
    sort = 156,
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_AbominationExplosion",
        "Interface\\Icons\\Spell_Fire_Flare",
    },
}

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("腐蚀术", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 30
    end

    local WarlockCorruptionDuration = 18
    WarlockCorruptionDuration = tonumber(Cat2.Match(Cat2.GetSpellTooltip("腐蚀术", "等级 1"), "腐蚀目标，在(%d+%.%d+)"))
    if not WarlockCorruptionDuration then
        WarlockCorruptionDuration = 18
    end
    Cat2.SetWarlockCorruptionDuration(WarlockCorruptionDuration)
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
            local hasCorruption = Cat2.Buff("腐蚀术", guid)
            if not hasCorruption and not Cat2.IsShadowImmune(guid) then
                if Cat2.CastSpellWithoutTarget("腐蚀术", guid) then
                    return true
                end
            end
        end
    end

    return false
end

Cat2.RegisterCard(card)
