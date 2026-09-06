-- 真言术：盾 技能卡片。
-- 使用与德鲁伊“迅捷愈合”一致的治疗目标选择机制，
-- 但不要求目标身上已有持续治疗效果。
local card = {
    id = "priest_power_word_shield",
    name = "真言术：盾",
    description = "根据|cffb87ff0[被动卡]|r规则，血量<|cff6bc7e0{triggerPercent}%|r时施放",
    details = "根据|cffb87ff0[被动卡]|r规则，血量低于卡片设定值时，在设定等级区间内施放真言术：盾。默认触发血量为99%。护盾没有按缺血量选级的旧数据表，因此优先尝试区间内最高可用等级。成功执行时会阻断本轮后续卡片。",
    sort = 5,
    category = "class",
    classes = {
        PRIEST = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_PowerWordShield",
    },
    cooldown = {
        type = "spell",
        name = "真言术：盾",
    },
    optionSchema = {
        { key = "triggerPercent", type = "number", label = "触发血量", unit = "%", default = 100, minimum = 1, maximum = 100 },
        { key = "minimumRank", type = "number", label = "最小等级", default = 1, minimum = 1, maximum = 10 },
        { key = "maximumRank", type = "number", label = "最大等级", default = 10, minimum = 1, maximum = 10 },
    },
}

local PriestPowerWordShieldMaxLevel = 10

function card.RefreshRuntimeData()
    PriestPowerWordShieldMaxLevel = Cat2.GetHighestRankOfSpell("真言术：盾")
end

-- 记录短时间内已处理的目标，避免同一轮或连续触发时重复套盾。
local healTargetDelay = {}

-- 判断目标是否适合施放真言术：盾，并在条件满足时完成施放。
function card.Health(unit, member, context, triggerPercent, minimumRank, maximumRank)

    if not unit then
        return false
    end

    local isDead = member and member.dead
    if not member then
        isDead = UnitIsDeadOrGhost(unit)
    end
    if isDead then
        return false
    end

    local health = member and member.health or UnitHealth(unit)
    local maximumHealth = member and member.maxHealth or UnitHealthMax(unit)
    if health == 0 or maximumHealth == 0 then
        return false
    end

    if UnitCanAttack("player", unit) then
        return false
    end

    local percentHealth = health / maximumHealth * 100
    if percentHealth >= triggerPercent then
        return false
    end

    if Cat2.UnitXP and unit ~= "player" then
        local inRange
        local inSight
        if member and context then
            inRange, inSight = context:GetTeamMemberRange(member)
        else
            inRange = UnitXP("distanceBetween", "player", unit)
        end
        if inRange and inRange > 40 then
            return false
        end
        if not member or not context then
            inSight = UnitXP("inSight", "player", unit)
        end
        if not inSight then
            return false
        end
    end

    if Cat2.Buff("真言术：盾", unit) or Cat2.Buff("虚弱灵魂", unit) then
        return false
    end

    local targetName = member and member.name or UnitName(unit)
    if targetName and healTargetDelay[targetName] and healTargetDelay[targetName] > GetTime() then
        return false
    end

    if PriestPowerWordShieldMaxLevel > 0 and Cat2.SpellReady("真言术：盾") then
        -- 护盾卡没有现有的护盾量/耗蓝等级表；在有效区间中从高到低尝试可施放等级。
        for rank = maximumRank, minimumRank, -1 do
            local castResult = Cat2.CastSpellWithoutTarget("真言术：盾(等级 "..rank..")", unit, 1)
            if castResult then
                if targetName then
                    healTargetDelay[targetName] = GetTime() + 1
                end
                return true
            end
        end
    end

    return false
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 99
    local minimumRank = context:GetStepOption(step, "minimumRank") or 1
    local maximumRank = context:GetStepOption(step, "maximumRank") or 10
    if maximumRank > PriestPowerWordShieldMaxLevel then maximumRank = PriestPowerWordShieldMaxLevel end
    if minimumRank > PriestPowerWordShieldMaxLevel then minimumRank = PriestPowerWordShieldMaxLevel end
    if minimumRank > maximumRank then minimumRank, maximumRank = maximumRank, minimumRank end

    if player.gcd > 0.2 then
        return false
    end
    if Cat2.GetIsCast() then
        return false
    end

    if not context:IsCardActive("shared_healing_team")
        and not context:IsCardActive("shared_random_healing_team")
        and not context:IsCardActive("shared_healing_team_priority_tank")
        and not context:IsCardActive("shared_healing_target_target")
        and not context:IsCardActive("shared_healing_target")
        and not context:IsCardActive("shared_healing_self")
        and not context:IsCardActive("shared_healing_party") then
        DEFAULT_CHAT_FRAME:AddMessage(Cat2.L("|cffffb347治疗技能缺少 |cffb87ff0[治疗指向]|r |cffffb347的被动卡|r"))
        return false
    end

    local targetFirst = context.parameters.HealingTarget
    if targetFirst and player.targetExists and card.Health("target", nil, context, triggerPercent, minimumRank, maximumRank) then
        return true
    end

    local targetTarget = context.parameters.HealingTargetTarget
    if targetTarget and player.targetExists and UnitExists("targettarget") and card.Health("targettarget", nil, context, triggerPercent, minimumRank, maximumRank) then
        return true
    end

    local selfFirst = context.parameters.HealingSelf
    if selfFirst and card.Health("player", nil, context, triggerPercent, minimumRank, maximumRank) then
        return true
    end

    local partyFirst = context.parameters.HealingParty
    if partyFirst then
        local partyMembers = context:GetTeamMembers("party", "health")
        for _, member in ipairs(partyMembers) do
            if card.Health(member.unit, member, context, triggerPercent, minimumRank, maximumRank) then
                return true
            end
        end
    end

    local randomTeam = context.parameters.RandomHealingRaid
    if randomTeam then
        local groupMembers = context:GetTeamMembers("group", "random")
        for _, member in ipairs(groupMembers) do
            if card.Health(member.unit, member, context, triggerPercent, minimumRank, maximumRank) then
                return true
            end
        end
    end

    local teamFirst = context.parameters.HealingRaid
    if teamFirst then
        local groupMembers = context:GetTeamMembers("group", "health")
        for _, member in ipairs(groupMembers) do
            if card.Health(member.unit, member, context, triggerPercent, minimumRank, maximumRank) then
                return true
            end
        end
    end

    local tankFirst = context.parameters.HealingTeamPriorityTank
    if tankFirst then
        local groupMembers = context:GetTeamMembers("group", "maxHealth")
        for _, member in ipairs(groupMembers) do
            if card.Health(member.unit, member, context, triggerPercent, minimumRank, maximumRank) then
                return true
            end
        end
    end

    return false
end

Cat2.RegisterCard(card)
