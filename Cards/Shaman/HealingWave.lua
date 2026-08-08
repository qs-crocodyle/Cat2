-- 治疗波 技能卡片。
local card = {
    id = "shaman_healing_wave",
    name = "治疗波",
    description = "根据|cffb87ff0[被动卡]|r规则，血量<70%施放自适配等级治疗波",
    details = "根据|cffb87ff0[被动卡]|r规则，血量<70%施放自适配等级治疗波。需要存在有效目标。仅对可攻击目标生效。会检查相关生命值。",
    sort = 10,
    category = "class",
    classes = {
        SHAMAN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_MagicImmunity",
    },
}

local ShamanHealingWave = {}
local ShamanHealingWaveEffect = {}
local ShamanHealingWaveFactor = 0.6
local ShamanHealingWaveMaxLevel = 10

function card.RefreshRuntimeData()
    local healingPower = Cat2.CalculateTotalHealingPower()
    local tidalFocus = 1-Cat2.IsTalentLearned(3, 2)*0.01

    ShamanHealingWave[1] = 25*tidalFocus
    ShamanHealingWaveEffect[1] = 41+(healingPower*ShamanHealingWaveFactor)
    ShamanHealingWave[2] = 45*tidalFocus
    ShamanHealingWaveEffect[2] = 76+(healingPower*ShamanHealingWaveFactor)
    ShamanHealingWave[3] = 80*tidalFocus
    ShamanHealingWaveEffect[3] = 149+(healingPower*ShamanHealingWaveFactor)
    ShamanHealingWave[4] = 155*tidalFocus
    ShamanHealingWaveEffect[4] = 303+(healingPower*ShamanHealingWaveFactor)
    ShamanHealingWave[5] = 200*tidalFocus
    ShamanHealingWaveEffect[5] = 421+(healingPower*ShamanHealingWaveFactor)
    ShamanHealingWave[6] = 265*tidalFocus
    ShamanHealingWaveEffect[6] = 595+(healingPower*ShamanHealingWaveFactor)
    ShamanHealingWave[7] = 340*tidalFocus
    ShamanHealingWaveEffect[7] = 816+(healingPower*ShamanHealingWaveFactor)
    ShamanHealingWave[8] = 440*tidalFocus
    ShamanHealingWaveEffect[8] = 1115+(healingPower*ShamanHealingWaveFactor)
    ShamanHealingWave[9] = 560*tidalFocus
    ShamanHealingWaveEffect[9] = 1486+(healingPower*ShamanHealingWaveFactor)
    ShamanHealingWave[10] = 620*tidalFocus
    ShamanHealingWaveEffect[10] = 1735+(healingPower*ShamanHealingWaveFactor)

    ShamanHealingWaveMaxLevel = Cat2.GetHighestRankOfSpell("治疗波")
end

local HasLesserHealingWave = false
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
    if health==0 or maxHealth==0 or UnitCanAttack("player", unit) then
        return false
    end

    local percentHealth = health/maxHealth*100
    if HasLesserHealingWave then
        if percentHealth>69.9 then
            return false
        end
    else
        if percentHealth>99.9 then
            return false
        end
    end

    local healthDeficit = maxHealth-health
    if healthDeficit < 10 then
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

    local targetName = member and member.name or UnitName(unit)
    if targetName and HealTargetDelay[targetName] and HealTargetDelay[targetName]-GetTime()>0 then
        return false
    end
    if targetName then
        HealTargetDelay[targetName] = GetTime()+1.0
    end

    if ShamanHealingWaveMaxLevel>0 then
        for i = ShamanHealingWaveMaxLevel, 1, -1 do
            if ShamanHealingWaveEffect[i] < healthDeficit then
                if Cat2.PlayerInformation.temporary.mana >= ShamanHealingWave[i] then
                    return Cat2.CastSpellWithoutTarget("治疗波(等级 "..i..")", unit, 1)
                end
                return Cat2.CastSpellWithoutTarget("治疗波(等级 1)", unit, 1)
            end
        end
        return Cat2.CastSpellWithoutTarget("治疗波(等级 1)", unit, 1)
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

    if context:IsCardActive("shaman_lesser_healing_wave") then
        HasLesserHealingWave = true
    else
        HasLesserHealingWave = false
    end

    local targetFirst = context and context.parameters and context.parameters.HealingTarget
    if targetFirst and player.targetExists and card.Health("target") then
        return
    end

    local targetTarget = context and context.parameters and context.parameters.HealingTargetTarget
    if targetTarget and player.targetExists and UnitExists("targettarget") and card.Health("targettarget") then
        return
    end

    local selfFirst = context and context.parameters and context.parameters.HealingSelf
    if selfFirst and card.Health("player") then
        return
    end

    local partyFirst = context and context.parameters and context.parameters.HealingParty
    if partyFirst then
        local sortedMembers = context:GetTeamMembers("party", "health")
        for i, member in ipairs(sortedMembers) do
            if card.Health(member.unit, member, context) then
                return
            end
        end
    end

    -- 小队/团队成员 - 随机
    local RandomScanTeam = context and context.parameters and context.parameters.RandomHealingRaid
    if RandomScanTeam then
        local sortedMembers = context:GetTeamMembers("group", "random")
        for i, member in ipairs(sortedMembers) do
            if card.Health(member.unit, member, context) then
                return
            end
        end
    end

    -- 小队/团队成员 - 血量最低
    local ScanTeam = context and context.parameters and context.parameters.HealingRaid
    if ScanTeam then
        local sortedMembers = context:GetTeamMembers("group", "health")
        for i, member in ipairs(sortedMembers) do
            if card.Health(member.unit, member, context) then
                return
            end
        end
    end

    -- 小队/团队成员 - 最大血量的最低
    local TankFirst = context and context.parameters and context.parameters.HealingTeamPriorityTank
    if TankFirst then
        local sortedMembers = context:GetTeamMembers("group", "maxHealth")
        for i, member in ipairs(sortedMembers) do
            if card.Health(member.unit, member, context) then
                return
            end
        end
    end

end

Cat2.RegisterCard(card)
