-- 次级治疗波 技能卡片。
local card = {
    id = "shaman_lesser_healing_wave",
    name = "次级治疗波",
    description = "根据|cffb87ff0[被动卡]|r规则，自适配等级施放次级治疗波",
    details = "根据|cffb87ff0[被动卡]|r规则，自适配等级施放次级治疗波。需要存在有效目标。仅对可攻击目标生效。会检查相关生命值。",
    sort = 20,
    category = "class",
    classes = {
        SHAMAN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_HealingWaveLesser",
    },
}

local ShamanLesserHealingWave = {}
local ShamanLesserHealingWaveEffect = {}
local ShamanLesserHealingWaveFactor = 0.55
local ShamanLesserHealingWaveMaxLevel = 6

function card.RefreshRuntimeData()
    local healingPower = Cat2.CalculateTotalHealingPower()
    local tidalFocus = 1-Cat2.IsTalentLearned(3, 2)*0.01

    ShamanLesserHealingWave[1] = 105*tidalFocus
    ShamanLesserHealingWaveEffect[1] = 177+(healingPower*ShamanLesserHealingWaveFactor)
    ShamanLesserHealingWave[2] = 145*tidalFocus
    ShamanLesserHealingWaveEffect[2] = 274+(healingPower*ShamanLesserHealingWaveFactor)
    ShamanLesserHealingWave[3] = 185*tidalFocus
    ShamanLesserHealingWaveEffect[3] = 371+(healingPower*ShamanLesserHealingWaveFactor)
    ShamanLesserHealingWave[4] = 235*tidalFocus
    ShamanLesserHealingWaveEffect[4] = 501+(healingPower*ShamanLesserHealingWaveFactor)
    ShamanLesserHealingWave[5] = 305*tidalFocus
    ShamanLesserHealingWaveEffect[5] = 686+(healingPower*ShamanLesserHealingWaveFactor)
    ShamanLesserHealingWave[6] = 380*tidalFocus
    ShamanLesserHealingWaveEffect[6] = 871+(healingPower*ShamanLesserHealingWaveFactor)

    ShamanLesserHealingWaveMaxLevel = Cat2.GetHighestRankOfSpell("次级治疗波")
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
    if health==0 or maxHealth==0 or UnitCanAttack("player", unit) then
        return false
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

    if ShamanLesserHealingWaveMaxLevel>0 then
        for i = ShamanLesserHealingWaveMaxLevel, 1, -1 do
            if ShamanLesserHealingWaveEffect[i] < healthDeficit then
                if Cat2.PlayerInformation.temporary.mana >= ShamanLesserHealingWave[i] then
                    return Cat2.CastSpellWithoutTarget("次级治疗波(等级 "..i..")", unit, 1)
                end
                return Cat2.CastSpellWithoutTarget("次级治疗波(等级 1)", unit, 1)
            end
        end
        return Cat2.CastSpellWithoutTarget("次级治疗波(等级 1)", unit, 1)
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
