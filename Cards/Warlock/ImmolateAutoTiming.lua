local card = {
    id = "warlock_immolate_auto_timing",
    name = "献祭（自动计时）",
    description = "自动计算献祭剩余时间补献祭",
    details = "根据目标身上的献祭剩余时间，结合施法时间重新施放，并保留现有的引导保护机制。需要存在有效目标；目标火焰免疫时不会施放。成功执行时会阻断本轮后续卡片。",
    sort = 20.5,
    category = "class",
    classes = {
        WARLOCK = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Immolation",
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
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 目标火焰免疫时，不再尝试施放火焰伤害技能。
    if Cat2.IsFireImmune() then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    local castTime = tonumber(Cat2.Match(Cat2.GetSpellTooltip("献祭"), "([0-9]+[.]?[0-9]*)秒施法时间")) - 0.1

    if not Cat2.GetImmolateDot("target", castTime) and (GetTime() - Cat2.GetImmolateTimer()) > 0 then
        Cat2.Cast("献祭")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
