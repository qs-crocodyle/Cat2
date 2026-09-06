local card = {
    id = "warlock_curse_of_shadow",
    name = "暗影诅咒",
    description = "保持并施放暗影诅咒",
    details = "保持并施放暗影诅咒。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 30,
    exclusiveGroup = "warlock_major_curse",
    category = "class",
    classes = { WARLOCK = 1 },
    icons = { "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde" },
}

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("暗影诅咒", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 30
    end
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    local onlyBoss = context and context.parameters and context.parameters.warlockMajorCurseOnlyBoss
    if onlyBoss and not Cat2.IsBossTarget() then
        return false
    end

    if not player.targetBuff["暗影诅咒"] then
        Cat2.Cast("暗影诅咒")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
