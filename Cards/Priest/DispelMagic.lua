-- 驱散魔法：按照治疗指向被动卡提供的顺序扫描友方单位。
local card = {
    id = "priest_dispel_magic",
    name = "驱散魔法",
    description = "根据|cffb87ff0[被动卡]|r规则，受到魔法减益时施放驱散魔法",
    details = "按照治疗指向被动卡提供的目标顺序扫描友方单位，发现魔法减益时施放驱散魔法。会检查施法状态、公共冷却、距离与视野。",
    sort = 150,
    category = "class",
    classes = {
        PRIEST = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_DispelMagic",
    },
}

local DispelMagicKnown = false
local DispelMagicTargetDelay = {}

function card.RefreshRuntimeData()
    DispelMagicKnown = Cat2.GetSpellID("驱散魔法") ~= 0
end

local function TryDispel(unit, member, context)
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
    if not Cat2.IsDebuffType("Magic", unit) then
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
        if inRange and inRange > 40 then
            return false
        end
        if not inSight then
            return false
        end
    end

    -- 防止同一目标在短时间内被连续重复尝试驱散。
    local targetName = member and member.name or UnitName(unit)
    if targetName then
        if DispelMagicTargetDelay[targetName] and DispelMagicTargetDelay[targetName] - GetTime() > 0 then
            return false
        end
        DispelMagicTargetDelay[targetName] = GetTime() + 1.0
    end

    if DispelMagicKnown then
        return Cat2.CastSpellWithoutTarget("驱散魔法", unit, 1)
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
        if TryDispel("target", nil, context) then
            return true
        end
    end

    if context.parameters.HealingTargetTarget and player.targetExists and UnitExists("targettarget") then
        if TryDispel("targettarget", nil, context) then
            return true
        end
    end

    if context.parameters.HealingSelf then
        if TryDispel("player", nil, context) then
            return true
        end
    end

    if context.parameters.HealingParty then
        local members = context:GetTeamMembers("party", "health")
        local index = 1
        while index <= table.getn(members) do
            local member = members[index]
            if TryDispel(member.unit, member, context) then
                return true
            end
            index = index + 1
        end
    end

    if context.parameters.RandomHealingRaid then
        local members = context:GetTeamMembers("group", "random")
        local index = 1
        while index <= table.getn(members) do
            local member = members[index]
            if TryDispel(member.unit, member, context) then
                return true
            end
            index = index + 1
        end
    end

    if context.parameters.HealingRaid then
        local members = context:GetTeamMembers("group", "health")
        local index = 1
        while index <= table.getn(members) do
            local member = members[index]
            if TryDispel(member.unit, member, context) then
                return true
            end
            index = index + 1
        end
    end

    if context.parameters.HealingTeamPriorityTank then
        local members = context:GetTeamMembers("group", "maxHealth")
        local index = 1
        while index <= table.getn(members) do
            local member = members[index]
            if TryDispel(member.unit, member, context) then
                return true
            end
            index = index + 1
        end
    end

    return false
end

Cat2.RegisterCard(card)
