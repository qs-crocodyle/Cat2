-- 真言术：盾（移动时）技能卡片。
--
-- 使用与普通真言术：盾相同的治疗目标选择机制，
-- 仅在角色移动中才会尝试施放，供移动治疗流程单独配置。
local card = {
    id = "priest_power_word_shield_move",
    name = "真言术：盾（移动时）",
    description = "移动时，根据|cffb87ff0[被动卡]|r规则，为低血量友方施放真言术：盾",
    details = "移动时，根据|cffb87ff0[被动卡]|r规则，为低血量友方施放真言术：盾。需要存在有效目标。仅对可攻击目标生效。会检查相关生命值。仅在技能可用时尝试执行。会检查移动状态。成功执行时会阻断本轮后续卡片。",
    sort = 6,
    category = "class",
    classes = {
        PRIEST = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_PowerWordShield",
    },
}

-- 初始化入口：预留给后续牧师治疗逻辑的缓存或事件注册。
function card.RefreshRuntimeData()
end

-- 记录短时间内已处理的目标，避免连续触发时重复套盾。
local healTargetDelay = {}

-- 判断目标是否适合施放真言术：盾，并在条件满足时完成施放。
function card.Health(unit, member, context)

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
    if percentHealth > 99.9 then
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

    if Cat2.GetHighestRankOfSpell("真言术：盾") > 0 and Cat2.SpellReady("真言术：盾") then
        local castResult = Cat2.CastSpellWithoutTarget("真言术：盾", unit, 1)
        if castResult and targetName then
            healTargetDelay[targetName] = GetTime() + 1
        end
        return castResult
    end

    return false
end

-- 仅在移动时扫描治疗目标，其他逻辑与普通真言术：盾保持一致。
function card.Execute(context)

    if not Cat2.PlayerIsMoving then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

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
        DEFAULT_CHAT_FRAME:AddMessage("|cffffb347治疗技能缺少 |cffb87ff0[治疗指向]|r |cffffb347的被动卡|r")
        return false
    end

    local targetFirst = context.parameters.HealingTarget
    if targetFirst and player.targetExists and card.Health("target") then
        return true
    end

    local targetTarget = context.parameters.HealingTargetTarget
    if targetTarget and player.targetExists and UnitExists("targettarget") and card.Health("targettarget") then
        return true
    end

    local selfFirst = context.parameters.HealingSelf
    if selfFirst and card.Health("player") then
        return true
    end

    local partyFirst = context.parameters.HealingParty
    if partyFirst then
        local partyMembers = context:GetTeamMembers("party", "health")
        for _, member in ipairs(partyMembers) do
            if card.Health(member.unit, member, context) then
                return true
            end
        end
    end

    local randomTeam = context.parameters.RandomHealingRaid
    if randomTeam then
        local groupMembers = context:GetTeamMembers("group", "random")
        for _, member in ipairs(groupMembers) do
            if card.Health(member.unit, member, context) then
                return true
            end
        end
    end

    local teamFirst = context.parameters.HealingRaid
    if teamFirst then
        local groupMembers = context:GetTeamMembers("group", "health")
        for _, member in ipairs(groupMembers) do
            if card.Health(member.unit, member, context) then
                return true
            end
        end
    end

    local tankFirst = context.parameters.HealingTeamPriorityTank
    if tankFirst then
        local groupMembers = context:GetTeamMembers("group", "maxHealth")
        for _, member in ipairs(groupMembers) do
            if card.Health(member.unit, member, context) then
                return true
            end
        end
    end

    return false
end

Cat2.RegisterCard(card)
