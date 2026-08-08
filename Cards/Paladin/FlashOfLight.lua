-- 圣光闪现 技能卡片。
local card = {
    id = "paladin_flash_of_light",
    name = "圣光闪现",
    description = "根据|cffb87ff0[被动卡]|r规则，自适配等级施放圣光闪现",
    details = "根据|cffb87ff0[被动卡]|r规则，自适配等级施放圣光闪现。需要存在有效目标。仅对可攻击目标生效。会检查相关生命值。成功执行时会阻断本轮后续卡片。",
    sort = 20,
    category = "class",
    classes = {
        PALADIN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_FlashHeal",
    },
}

-- 圣光闪现
local PaladinFlashLight = {}
local PaladinFlashLightEffect = {}
local PaladinFlashLightFactor = 0.7
local PaladinFlashLightMaxLevel = 7


function card.RefreshRuntimeData()

    local HealingPower = Cat2.CalculateTotalHealingPower()

    PaladinFlashLight[1] = 35
    PaladinFlashLightEffect[1] = 72+(HealingPower*PaladinFlashLightFactor)
    PaladinFlashLight[2] = 50
    PaladinFlashLightEffect[2] = 109+(HealingPower*PaladinFlashLightFactor)
    PaladinFlashLight[3] = 70
    PaladinFlashLightEffect[3] = 162+(HealingPower*PaladinFlashLightFactor)
    PaladinFlashLight[4] = 90
    PaladinFlashLightEffect[4] = 219+(HealingPower*PaladinFlashLightFactor)
    PaladinFlashLight[5] = 115
    PaladinFlashLightEffect[5] = 295+(HealingPower*PaladinFlashLightFactor)
    PaladinFlashLight[6] = 140
    PaladinFlashLightEffect[6] = 365+(HealingPower*PaladinFlashLightFactor)
    PaladinFlashLight[7] = 180
    PaladinFlashLightEffect[7] = 460+(HealingPower*PaladinFlashLightFactor)

    PaladinFlashLightMaxLevel = Cat2.GetHighestRankOfSpell("圣光闪现")
end


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
    if HealTargetDelay[targetName] and HealTargetDelay[targetName]-GetTime()>0 then
        return false
    end
    HealTargetDelay[targetName] = GetTime()+1.0

    -- 读圣光术

    -- 先确保技能已学
    if PaladinFlashLightMaxLevel>0 then

        -- 根据配置等级和所学等级计算
        for i = PaladinFlashLightMaxLevel, 1, -1 do
            if PaladinFlashLightEffect[i] < HealthDec then

                if Cat2.PlayerInformation.temporary.mana >= PaladinFlashLight[i] then
                    return Cat2.CastSpellWithoutTarget("圣光闪现(等级 "..i..")", unit, 1)
                else
                    return Cat2.CastSpellWithoutTarget("圣光闪现(等级 1)", unit, 1)
                end

            end
        end

        return Cat2.CastSpellWithoutTarget("圣光闪现(等级 1)", unit, 1)

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
