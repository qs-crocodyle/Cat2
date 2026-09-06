-- 献祭（多线DOT）技能卡片。
local card = {
    id = "warlock_immolate_multi_dot",
    name = "献祭（多线DOT）",
    description = "为附近没有献祭的敌人施放献祭",
    details = "扫描献祭射程内的敌人，并对其中没有献祭、不免疫火焰伤害且处于玩家正面的目标无目标施放献祭。需要 SuperWoW；每轮最多选择一个敌人施放。",
    sort = 67,
    category = "class",
    classes = {
        WARLOCK = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Immolation",
        "Interface\\Icons\\Spell_Fire_Flare",
    },
}

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("献祭", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 30
    end
end

function card.Execute(context)
    if not Cat2.SuperWoW then
        return false
    end

    -- 无目标施法入口会直接调用 CastSpellByName，因此在这里补齐普通 Cat2.Cast 的引导保护。
    if Cat2.GetChanneled() >= 0.08 then
        return false
    end

    -- 献祭是读条法术，保留原有的防重复施放计时。
    if (GetTime() - Cat2.GetImmolateTimer()) <= 0 then
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
            local isInFront = true
            if Cat2.UnitXP then
                isInFront = not UnitXP("behind", guid, "player")
            end

            if isInFront and not Cat2.GetImmolateDot(guid) and not Cat2.IsFireImmune(guid) then
                if Cat2.CastSpellWithoutTarget("献祭", guid) then
                    return true
                end
            end
        end
    end

    return false
end

Cat2.RegisterCard(card)
