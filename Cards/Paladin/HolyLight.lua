-- 圣光术 技能卡片。
local card = {
    id = "paladin_holy_light",
    name = "圣光术",
    description = "根据|cffb87ff0[被动卡]|r规则，血量<70%施放自适配等级圣光术",
    details = "根据|cffb87ff0[被动卡]|r规则，血量<70%施放自适配等级圣光术。需要存在有效目标。仅对可攻击目标生效。会检查相关生命值。成功执行时会阻断本轮后续卡片。",
    sort = 10,
    category = "class",
    classes = {
        PALADIN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_HolyBolt",
    },
}

-- 圣光术
local PaladinHolyLight = {}
local PaladinHolyLightEffect = {}
local PaladinHolyLightFactor = 1.4
local PaladinHolyLightMaxLevel = 9

function card.RefreshRuntimeData()

    local HealingPower = Cat2.CalculateTotalHealingPower()

    PaladinHolyLight[1] = 35
    PaladinHolyLightEffect[1] = 46+(HealingPower*PaladinHolyLightFactor)
    PaladinHolyLight[2] = 60
    PaladinHolyLightEffect[2] = 89+(HealingPower*PaladinHolyLightFactor)
    PaladinHolyLight[3] = 110
    PaladinHolyLightEffect[3] = 184+(HealingPower*PaladinHolyLightFactor)
    PaladinHolyLight[4] = 190
    PaladinHolyLightEffect[4] = 350+(HealingPower*PaladinHolyLightFactor)
    PaladinHolyLight[5] = 275
    PaladinHolyLightEffect[5] = 538+(HealingPower*PaladinHolyLightFactor)
    PaladinHolyLight[6] = 365
    PaladinHolyLightEffect[6] = 758+(HealingPower*PaladinHolyLightFactor)
    PaladinHolyLight[7] = 465
    PaladinHolyLightEffect[7] = 1018+(HealingPower*PaladinHolyLightFactor)
    PaladinHolyLight[8] = 580
    PaladinHolyLightEffect[8] = 1342+(HealingPower*PaladinHolyLightFactor)
    PaladinHolyLight[9] = 660
    PaladinHolyLightEffect[9] = 1680+(HealingPower*PaladinHolyLightFactor)

    PaladinHolyLightMaxLevel = Cat2.GetHighestRankOfSpell("圣光术")
end

local HasFlash = true
local HealTargetDelay = {}

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

    if health==0 or maxHealth == 0 then
        -- 离线忽略 死亡忽略
        return false
    end

    -- 敌人
    if UnitCanAttack("player", unit) then
        return false
    end

    local percentHealth = health/maxHealth * 100

    -- 没有圣光闪现治疗起点修改为99%
    if HasFlash then
        if percentHealth > 69.9 then
            return false
        end
    else
        if percentHealth > 99.9 then
            return false
        end
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

    -- 读圣光术

    -- 先确保技能已学
    if PaladinHolyLightMaxLevel>0 then

        -- 根据配置等级和所学等级计算
        for i = PaladinHolyLightMaxLevel, 1, -1 do
            if PaladinHolyLightEffect[i] < HealthDec then

                if Cat2.PlayerInformation.temporary.mana >= PaladinHolyLight[i] then
                    return Cat2.CastSpellWithoutTarget("圣光术(等级 "..i..")", unit, 1)
                else
                    return Cat2.CastSpellWithoutTarget("圣光术(等级 1)", unit, 1)
                end

            end
        end

        return Cat2.CastSpellWithoutTarget("圣光术(等级 1)", unit, 1)

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

    -- 判断队列中是否存在圣光闪现
    -- 没有圣光闪现治疗起点修改为99%
    if context:IsCardActive("paladin_flash_of_light") then
        HasFlash = true
    else
        HasFlash = false
    end

    -- 目标
    local TargetFirst = context and context.parameters and context.parameters.HealingTarget
    if TargetFirst and player.targetExists then
        if card.Health("target") then
            return true
        end
    end

    -- 目标 的 目标
    local TargetTarget = context and context.parameters and context.parameters.HealingTargetTarget
    if TargetTarget and player.targetExists and UnitExists("targettarget") then
        if card.Health("targettarget") then
            return true
        end
    end

    -- 自己
    local SelfFirst = context and context.parameters and context.parameters.HealingSelf
    if SelfFirst then
        if card.Health("player") then
            return true
        end
    end

    -- 小队成员
    local PartyFirst = context and context.parameters and context.parameters.HealingParty
    if PartyFirst then
        local sortedMembers = context:GetTeamMembers("party", "health")
        for i, member in ipairs(sortedMembers) do
            if card.Health(member.unit, member, context) then
                return true
            end
        end
    end

    -- 小队/团队成员 - 随机
    local RandomScanTeam = context and context.parameters and context.parameters.RandomHealingRaid
    if RandomScanTeam then
        local sortedMembers = context:GetTeamMembers("group", "random")
            
        for i, member in ipairs(sortedMembers) do
            if card.Health(member.unit, member, context) then
                return true
            end
        end
    end

    -- 小队/团队成员 - 血量最低
    local ScanTeam = context and context.parameters and context.parameters.HealingRaid
    if ScanTeam then
        local sortedMembers = context:GetTeamMembers("group", "health")
        for i, member in ipairs(sortedMembers) do
            if card.Health(member.unit, member, context) then
                return true
            end
        end
    end

    -- 小队/团队成员 - 最大血量的最低
    local TankFirst = context and context.parameters and context.parameters.HealingTeamPriorityTank
    if TankFirst then
        local sortedMembers = context:GetTeamMembers("group", "maxHealth")
        for i, member in ipairs(sortedMembers) do
            if card.Health(member.unit, member, context) then
                return true
            end
        end
    end

    return false
end

Cat2.RegisterCard(card)
