-- 恢复 技能卡片。
-- 使用与真言术：盾相同的治疗目标选择机制，
-- 但以“恢复”持续治疗效果作为防重复施放判定。
local card = {
    id = "priest_renew",
    name = "恢复",
    description = "根据|cffb87ff0[被动卡]|r规则，自适配等级施放恢复",
    details = "根据|cffb87ff0[被动卡]|r规则，自适配等级施放恢复。需要存在有效目标。仅对可攻击目标生效。会检查相关生命值。成功执行时会阻断本轮后续卡片。",
    sort = 50,
    category = "class",
    classes = {
        PRIEST = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_Renew",
    },
}

-- 恢复
local PriestRenewMana = {}
local PriestRenewEffect = {}
local PriestRenewFactor = 0.6
local PriestRenewManaMaxLevel = 10

function card.RefreshRuntimeData()

    local MentalAgility = 1 - (Cat2.IsTalentLearned(1, 3) * 0.05)
    local EffectPercent = 1 + (Cat2.IsTalentLearned(2,1)*0.05) + (Cat2.IsTalentLearned(2,15)*0.06)

    local HealingPower = Cat2.CalculateTotalHealingPower()

    -- 恢复属性
    PriestRenewMana[1] = 26 * MentalAgility
    PriestRenewEffect[1] = (45+(HealingPower*PriestRenewFactor)) * EffectPercent
    PriestRenewMana[2] = 57 * MentalAgility
    PriestRenewEffect[2] = (100+(HealingPower*PriestRenewFactor)) * EffectPercent
    PriestRenewMana[3] = 92 * MentalAgility
    PriestRenewEffect[3] = (175+(HealingPower*PriestRenewFactor)) * EffectPercent
    PriestRenewMana[4] = 123 * MentalAgility
    PriestRenewEffect[4] = (245+(HealingPower*PriestRenewFactor)) * EffectPercent
    PriestRenewMana[5] = 149 * MentalAgility
    PriestRenewEffect[5] = (270+(HealingPower*PriestRenewFactor)) * EffectPercent
    PriestRenewMana[6] = 180 * MentalAgility
    PriestRenewEffect[6] = (340+(HealingPower*PriestRenewFactor)) * EffectPercent
    PriestRenewMana[7] = 220 * MentalAgility
    PriestRenewEffect[7] = (435+(HealingPower*PriestRenewFactor)) * EffectPercent
    PriestRenewMana[8] = 268 * MentalAgility
    PriestRenewEffect[8] = (555+(HealingPower*PriestRenewFactor)) * EffectPercent
    PriestRenewMana[9] = 321 * MentalAgility
    PriestRenewEffect[9] = (690+(HealingPower*PriestRenewFactor)) * EffectPercent
    PriestRenewMana[10] = 360 * MentalAgility
    PriestRenewEffect[10] = (825+(HealingPower*PriestRenewFactor)) * EffectPercent

    PriestRenewManaMaxLevel = Cat2.GetHighestRankOfSpell("恢复")

end

-- 记录短时间内已处理的目标，避免连续触发时重复施放恢复。
local healTargetDelay = {}

-- 判断目标是否适合施放恢复，并在条件满足时完成施放。
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
    local maxHealth = member and member.maxHealth or UnitHealthMax(unit)
    if health == 0 or maxHealth == 0 then
        return false
    end

    if UnitCanAttack("player", unit) then
        return false
    end

    local percentHealth = health / maxHealth * 100
    if percentHealth > 99.9 then
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

    -- 已有恢复时不重复施放；与真言术盾不同，不检查虚弱灵魂。
    if Cat2.Buff("恢复", unit) then
        return false
    end

    local targetName = member and member.name or UnitName(unit)
    if targetName and healTargetDelay[targetName] and healTargetDelay[targetName] > GetTime() then
        return false
    end
    healTargetDelay[targetName] = GetTime()+1.0

    if PriestRenewManaMaxLevel > 0 then

        -- 根据配置等级和所学等级计算
        for i = PriestRenewManaMaxLevel, 1, -1 do
            if PriestRenewEffect[i] < HealthDec then

                if Cat2.PlayerInformation.temporary.mana >= PriestRenewMana[i] then
                    return Cat2.CastSpellWithoutTarget("恢复(等级 "..i..")", unit, 1)
                else
                    return Cat2.CastSpellWithoutTarget("恢复(等级 1)", unit, 1)
                end

            end
        end

        return Cat2.CastSpellWithoutTarget("恢复(等级 1)", unit, 1)
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
