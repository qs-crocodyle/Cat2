-- 快速治疗 技能卡片。
local card = {
    id = "priest_flash_heal",
    name = "快速治疗",
    description = "根据|cffb87ff0[被动卡]|r规则，血量<|cff6bc7e0{triggerPercent}%|r时自适配等级施放",
    details = "根据|cffb87ff0[被动卡]|r规则，血量低于卡片设定值时，在设定等级区间内自适配等级施放快速治疗。默认触发血量为99%。需要存在有效目标。仅对可攻击目标生效。会检查相关生命值。",
    sort = 30,
    category = "class",
    classes = {
        PRIEST = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_FlashHeal",
    },
    castProfile = {
        spellNames = {
            "快速治疗",
        },
        tags = {
            healing = true,
            singleTarget = true,
            fullHealthCancelable = true,
        },
    },
    optionSchema = {
        { key = "triggerPercent", type = "number", label = "触发血量", unit = "%", default = 99, minimum = 1, maximum = 99 },
        { key = "minimumRank", type = "number", label = "最小等级", default = 1, minimum = 1, maximum = 7 },
        { key = "maximumRank", type = "number", label = "最大等级", default = 7, minimum = 1, maximum = 7 },
    },
}

-- 快速治疗
local PriestFlashHealMana = {}
local PriestFlashHealEffect = {}
local PriestFlashHealFactor = 0.7
local PriestFlashHealMaxLevel = 7

function card.RefreshRuntimeData()

    local EffectPercent = 1 + (Cat2.IsTalentLearned(2,1)*0.05) + (Cat2.IsTalentLearned(2,15)*0.06)
    local GreaterHeal = 1 - (Cat2.IsTalentLearned(2,11)*0.05)

    local HealingPower = Cat2.CalculateTotalHealingPower()

    PriestFlashHealMana[1] = 125
    PriestFlashHealEffect[1] = (220+(HealingPower*PriestFlashHealFactor)) * EffectPercent
    PriestFlashHealMana[2] = 155
    PriestFlashHealEffect[2] = (290+(HealingPower*PriestFlashHealFactor)) * EffectPercent
    PriestFlashHealMana[3] = 185
    PriestFlashHealEffect[3] = (320+(HealingPower*PriestFlashHealFactor)) * EffectPercent
    PriestFlashHealMana[4] = 215
    PriestFlashHealEffect[4] = (390+(HealingPower*PriestFlashHealFactor)) * EffectPercent
    PriestFlashHealMana[5] = 265
    PriestFlashHealEffect[5] = (500+(HealingPower*PriestFlashHealFactor)) * EffectPercent
    PriestFlashHealMana[6] = 315
    PriestFlashHealEffect[6] = (610+(HealingPower*PriestFlashHealFactor)) * EffectPercent
    PriestFlashHealMana[7] = 380
    PriestFlashHealEffect[7] = (770+(HealingPower*PriestFlashHealFactor)) * EffectPercent

    PriestFlashHealMaxLevel = Cat2.GetHighestRankOfSpell("快速治疗")
end

local HealTargetDelay = {}

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
    local maxHealth = member and member.maxHealth or UnitHealthMax(unit)

    if health==0 or maxHealth == 0 then
        -- 离线忽略 死亡忽略
        return false
    end

    -- 敌人
    if UnitCanAttack("player", unit) then
        return false
    end

    local percentHealth = health/maxHealth * 100
    if percentHealth >= triggerPercent then
        return false
    end

    local HealthDec = maxHealth - health
    if HealthDec < 10 then
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

    -- 用于防止1秒同一目标多次治疗
    local targetName = member and member.name or UnitName(unit)
    if targetName and HealTargetDelay[targetName] and HealTargetDelay[targetName]-GetTime()>0 then
        return false
    end
    HealTargetDelay[targetName] = GetTime()+1.0

    -- 读快速治疗

    -- 先确保技能已学
    if PriestFlashHealMaxLevel>0 then

        for i = maximumRank, minimumRank, -1 do
            if PriestFlashHealEffect[i] < HealthDec and Cat2.PlayerInformation.temporary.mana >= PriestFlashHealMana[i] then
                return Cat2.CastSpellWithoutTarget("快速治疗(等级 "..i..")", unit, 1)
            end
        end
        if Cat2.PlayerInformation.temporary.mana >= PriestFlashHealMana[minimumRank] then
            return Cat2.CastSpellWithoutTarget("快速治疗(等级 "..minimumRank..")", unit, 1)
        end

    end


    return false
end


function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 99
    local minimumRank = context:GetStepOption(step, "minimumRank") or 1
    local maximumRank = context:GetStepOption(step, "maximumRank") or 7
    if maximumRank > PriestFlashHealMaxLevel then maximumRank = PriestFlashHealMaxLevel end
    if minimumRank > PriestFlashHealMaxLevel then minimumRank = PriestFlashHealMaxLevel end
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


    -- 目标
    local TargetFirst = context and context.parameters and context.parameters.HealingTarget
    if TargetFirst and player.targetExists then
        if card.Health("target", nil, context, triggerPercent, minimumRank, maximumRank) then
            return
        end
    end

    -- 目标 的 目标
    local TargetTarget = context and context.parameters and context.parameters.HealingTargetTarget
    if TargetTarget and player.targetExists and UnitExists("targettarget") then
        if card.Health("targettarget", nil, context, triggerPercent, minimumRank, maximumRank) then
            return
        end
    end

    -- 自己
    local SelfFirst = context and context.parameters and context.parameters.HealingSelf
    if SelfFirst then
        if card.Health("player", nil, context, triggerPercent, minimumRank, maximumRank) then
            return
        end
    end

    -- 小队成员
    local PartyFirst = context and context.parameters and context.parameters.HealingParty
    if PartyFirst then
        local sortedMembers = context:GetTeamMembers("party", "health")
        for i, member in ipairs(sortedMembers) do
            if card.Health(member.unit, member, context, triggerPercent, minimumRank, maximumRank) then
                return
            end
        end
    end

    -- 小队/团队成员 - 随机
    local RandomScanTeam = context and context.parameters and context.parameters.RandomHealingRaid
    if RandomScanTeam then
        local sortedMembers = context:GetTeamMembers("group", "random")
            
        for i, member in ipairs(sortedMembers) do
            if card.Health(member.unit, member, context, triggerPercent, minimumRank, maximumRank) then
                return
            end
        end
    end

    -- 小队/团队成员 - 血量最低
    local ScanTeam = context and context.parameters and context.parameters.HealingRaid
    if ScanTeam then
        local sortedMembers = context:GetTeamMembers("group", "health")
        for i, member in ipairs(sortedMembers) do
            if card.Health(member.unit, member, context, triggerPercent, minimumRank, maximumRank) then
                return
            end
        end
    end

    -- 小队/团队成员 - 最大血量的最低
    local TankFirst = context and context.parameters and context.parameters.HealingTeamPriorityTank
    if TankFirst then
        local sortedMembers = context:GetTeamMembers("group", "maxHealth")
        for i, member in ipairs(sortedMembers) do
            if card.Health(member.unit, member, context, triggerPercent, minimumRank, maximumRank) then
                return
            end
        end
    end

end

Cat2.RegisterCard(card)
