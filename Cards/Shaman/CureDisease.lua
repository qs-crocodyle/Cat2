-- 祛病术：按照治疗指向被动卡提供的顺序扫描友方单位。
local card = {
    id = "shaman_cure_disease",
    name = "祛病术",
    description = "根据|cffb87ff0[被动卡]|r规则，染病时施放祛病术",
    details = "按照治疗指向被动卡提供的目标顺序扫描友方单位，发现疾病效果时施放祛病术。会检查施法状态、公共冷却、距离与视野。",
    sort = 70,
    category = "class",
    classes = {
        SHAMAN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_NullifyDisease",
    },
}

local CureDiseaseKnown = false
local CureDiseaseTargetDelay = {}

function card.RefreshRuntimeData()
    CureDiseaseKnown = Cat2.GetSpellID("祛病术") ~= 0
end

local function TryCureDisease(unit, member, context)
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
    if not Cat2.IsDebuffType("Disease", unit) then
        return false
    end

    if Cat2.UnitXP and unit ~= "player" then
        local inRange
        local inSight
        if member and context then
            inRange, inSight = context:GetTeamMemberRange(member)
        else
            inRange = UnitXP("distanceBetween", "player", unit)
            inSight = UnitXP("inSight", "player", unit)
        end
        if inRange and inRange > 40 then
            return false
        end
        if not inSight then
            return false
        end
    end

    local targetName = member and member.name or UnitName(unit)
    if targetName then
        if CureDiseaseTargetDelay[targetName] and CureDiseaseTargetDelay[targetName] - GetTime() > 0 then
            return false
        end
        CureDiseaseTargetDelay[targetName] = GetTime() + 1.0
    end

    if CureDiseaseKnown then
        return Cat2.CastSpellWithoutTarget("祛病术", unit, 1)
    end

    return false
end


local function HasHealingDirection(context)
    return context:IsCardActive("shared_healing_team")
        or context:IsCardActive("shared_random_healing_team")
        or context:IsCardActive("shared_healing_team_priority_tank")
        or context:IsCardActive("shared_healing_target_target")
        or context:IsCardActive("shared_healing_target")
        or context:IsCardActive("shared_healing_self")
        or context:IsCardActive("shared_healing_party")
end

local function TryMembers(context, scope, order)
    local members = context:GetTeamMembers(scope, order)
    local index = 1
    while index <= table.getn(members) do
        local member = members[index]
        if TryCureDisease(member.unit, member, context) then
            return true
        end
        index = index + 1
    end
    return false
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if player.gcd > 0.2 or Cat2.GetIsCast() then
        return false
    end
    if not HasHealingDirection(context) then
        DEFAULT_CHAT_FRAME:AddMessage(Cat2.L("|cffffb347驱散技能缺少 |cffb87ff0[治疗指向]|r |cffffb347的被动卡|r"))
        return false
    end

    if context.parameters.HealingTarget and player.targetExists and TryCureDisease("target", nil, context) then
        return true
    end
    if context.parameters.HealingTargetTarget and player.targetExists and UnitExists("targettarget") and TryCureDisease("targettarget", nil, context) then
        return true
    end
    if context.parameters.HealingSelf and TryCureDisease("player", nil, context) then
        return true
    end
    if context.parameters.HealingParty and TryMembers(context, "party", "health") then
        return true
    end
    if context.parameters.RandomHealingRaid and TryMembers(context, "group", "random") then
        return true
    end
    if context.parameters.HealingRaid and TryMembers(context, "group", "health") then
        return true
    end
    if context.parameters.HealingTeamPriorityTank and TryMembers(context, "group", "maxHealth") then
        return true
    end

    return false
end

Cat2.RegisterCard(card)
