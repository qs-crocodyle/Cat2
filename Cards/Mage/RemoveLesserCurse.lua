-- 解除次级诅咒：按照治疗指向被动卡提供的顺序扫描友方单位。
local card = {
    id = "mage_remove_lesser_curse",
    name = "解除次级诅咒",
    description = "根据|cffb87ff0[被动卡]|r规则，受诅咒时施放解除次级诅咒",
    details = "按照治疗指向被动卡提供的目标顺序扫描友方单位，发现诅咒效果时施放解除次级诅咒。会检查施法状态、公共冷却、距离与视野。",
    sort = 180,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_RemoveCurse",
    },
}

local RemoveLesserCurseMaxLevel = 0
local RemoveLesserCurseTargetDelay = {}

function card.RefreshRuntimeData()
    RemoveLesserCurseMaxLevel = 1
end

function card.Remove(unit, member, context)
    if not unit then
        return false
    end

    local isDead = member and member.dead
    if not member then
        isDead = UnitIsDeadOrGhost(unit)
    end
    if isDead or UnitCanAttack("player", unit) then
        return false
    end
    if not Cat2.IsDebuffType("Curse", unit) then
        return false
    end

    -- 团队快照已缓存距离与视野，其他目标在需要时即时检查。
    if Cat2.UnitXP and unit ~= "player" then
        local inRange
        local inSight
        if member and context then
            inRange, inSight = context:GetTeamMemberRange(member)
        else
            inRange = UnitXP("distanceBetween", "player", unit)
            inSight = UnitXP("inSight", "player", unit)
        end
        if inRange and inRange > 30 then
            return false
        end
        if not inSight then
            return false
        end
    end

    -- 防止同一目标在短时间内被连续重复尝试驱散。
    local targetName = member and member.name or UnitName(unit)
    if targetName and RemoveLesserCurseTargetDelay[targetName] and RemoveLesserCurseTargetDelay[targetName] - GetTime() > 0 then
        return false
    end
    RemoveLesserCurseTargetDelay[targetName] = GetTime() + 1.0

    if RemoveLesserCurseMaxLevel > 0 then
        return Cat2.CastSpellWithoutTarget("解除次级诅咒", unit, 1)
    end

    return false
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if player.gcd > 0.2 or Cat2.GetIsCast() then
        return false
    end

    if not context:IsCardActive("shared_healing_team")
    and not context:IsCardActive("shared_random_healing_team")
    and not context:IsCardActive("shared_healing_team_priority_tank")
    and not context:IsCardActive("shared_healing_target_target")
    and not context:IsCardActive("shared_healing_target")
    and not context:IsCardActive("shared_healing_self")
    and not context:IsCardActive("shared_healing_party") then
        DEFAULT_CHAT_FRAME:AddMessage(Cat2.L("|cffffb347驱散技能缺少 |cffb87ff0[治疗指向]|r |cffffb347的被动卡|r"))
        return false
    end

    if context.parameters.HealingTarget and player.targetExists then
        if card.Remove("target", nil, context) then
            return true
        end
    end

    if context.parameters.HealingTargetTarget and player.targetExists and UnitExists("targettarget") then
        if card.Remove("targettarget", nil, context) then
            return true
        end
    end

    if context.parameters.HealingSelf then
        if card.Remove("player", nil, context) then
            return true
        end
    end

    if context.parameters.HealingParty then
        local sortedMembers = context:GetTeamMembers("party", "health")
        local memberIndex = 1
        local memberTotal = table.getn(sortedMembers)
        while memberIndex <= memberTotal do
            local member = sortedMembers[memberIndex]
            if card.Remove(member.unit, member, context) then
                return true
            end
            memberIndex = memberIndex + 1
        end
    end

    if context.parameters.RandomHealingRaid then
        local sortedMembers = context:GetTeamMembers("group", "random")
        local memberIndex = 1
        local memberTotal = table.getn(sortedMembers)
        while memberIndex <= memberTotal do
            local member = sortedMembers[memberIndex]
            if card.Remove(member.unit, member, context) then
                return true
            end
            memberIndex = memberIndex + 1
        end
    end

    if context.parameters.HealingRaid then
        local sortedMembers = context:GetTeamMembers("group", "health")
        local memberIndex = 1
        local memberTotal = table.getn(sortedMembers)
        while memberIndex <= memberTotal do
            local member = sortedMembers[memberIndex]
            if card.Remove(member.unit, member, context) then
                return true
            end
            memberIndex = memberIndex + 1
        end
    end

    if context.parameters.HealingTeamPriorityTank then
        local sortedMembers = context:GetTeamMembers("group", "maxHealth")
        local memberIndex = 1
        local memberTotal = table.getn(sortedMembers)
        while memberIndex <= memberTotal do
            local member = sortedMembers[memberIndex]
            if card.Remove(member.unit, member, context) then
                return true
            end
            memberIndex = memberIndex + 1
        end
    end

    return false
end

Cat2.RegisterCard(card)
