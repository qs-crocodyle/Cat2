-- 驱毒术：解除友方目标当前的中毒效果，并提供持续驱毒效果。
local card = {
    id = "druid_abolish_poison",
    name = "驱毒术",
    description = "根据|cffb87ff0[被动卡]|r规则，中毒时施放驱毒术",
    details = "当前目标为存活友方且带有中毒效果时施放驱毒术。仅在技能可用时尝试执行，成功施放后阻断本轮后续卡片。",
    sort = 270,
    category = "class",
    classes = {
        DRUID = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_NullifyPoison",
    },
}

local AbolishPoisonMaxLevel = 0

function card.RefreshRuntimeData()
    AbolishPoisonMaxLevel = 1 --Cat2.GetHighestRankOfSpell("躯毒术")
end

local AbolishTargetDelay = {}

function card.Abolish(unit, member, context)

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

    -- 敌人
    if UnitCanAttack("player", unit) then
        return false
    end

    if not Cat2.IsDebuffType("Poison", unit) then
        return false
    end

    -- 目标是否已经有驱毒术
    if Cat2.Buff("驱毒术",unit) then
        return false
    end

    -- 视野
    if Cat2.UnitXP and unit ~= "player" then
        local inRange
        local inSight
        if member and context then
            inRange, inSight = context:GetTeamMemberRange(member)
        else
            inRange = UnitXP("distanceBetween", "player", unit)
        end
        if inRange and inRange > 30 then
            return false
        end
        if not member or not context then
            inSight = UnitXP("inSight", "player", unit)
        end
        if not inSight then
            return false
        end
    end

    -- 用于防止1秒同一目标多次驱散
    local targetName = member and member.name or UnitName(unit)
    if targetName and AbolishTargetDelay[targetName] and AbolishTargetDelay[targetName]-GetTime()>0 then
        return false
    end
    AbolishTargetDelay[targetName] = GetTime()+1.0

    -- 确保躯毒术已经习得
    if AbolishPoisonMaxLevel>0 then
        return Cat2.CastSpellWithoutTarget("驱毒术", unit, 1)
    end

    return false
end


function card.Execute(context)
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
        DEFAULT_CHAT_FRAME:AddMessage(Cat2.L("|cffffb347驱散技能缺少 |cffb87ff0[治疗指向]|r |cffffb347的被动卡|r"))
        return false
    end

    -- 目标
    local TargetFirst = context and context.parameters and context.parameters.HealingTarget
    if TargetFirst and player.targetExists then
        if card.Abolish("target", nil, context) then
            return
        end
    end

    -- 目标 的 目标
    local TargetTarget = context and context.parameters and context.parameters.HealingTargetTarget
    if TargetTarget and player.targetExists and UnitExists("targettarget") then
        if card.Abolish("targettarget", nil, context) then
            return
        end
    end

    -- 自己
    local SelfFirst = context and context.parameters and context.parameters.HealingSelf
    if SelfFirst then
        if card.Abolish("player", nil, context) then
            return
        end
    end

    -- 小队成员
    local PartyFirst = context and context.parameters and context.parameters.HealingParty
    if PartyFirst then
        local sortedMembers = context:GetTeamMembers("party", "health")
        for i, member in ipairs(sortedMembers) do
            if card.Abolish(member.unit, member, context) then
                return
            end
        end
    end

    -- 小队/团队成员 - 随机
    local RandomScanTeam = context and context.parameters and context.parameters.RandomHealingRaid
    if RandomScanTeam then
        local sortedMembers = context:GetTeamMembers("group", "random")
            
        for i, member in ipairs(sortedMembers) do
            if card.Abolish(member.unit, member, context) then
                return
            end
        end
    end

    -- 小队/团队成员 - 血量最低
    local ScanTeam = context and context.parameters and context.parameters.HealingRaid
    if ScanTeam then
        local sortedMembers = context:GetTeamMembers("group", "health")
        for i, member in ipairs(sortedMembers) do
            if card.Abolish(member.unit, member, context) then
                return
            end
        end
    end

    -- 小队/团队成员 - 最大血量的最低
    local TankFirst = context and context.parameters and context.parameters.HealingTeamPriorityTank
    if TankFirst then
        local sortedMembers = context:GetTeamMembers("group", "maxHealth")
        for i, member in ipairs(sortedMembers) do
            if card.Abolish(member.unit, member, context) then
                return
            end
        end
    end

end

Cat2.RegisterCard(card)
