-- 先祖迅捷 技能卡片。
local card = {
    id = "shaman_ancestral_swiftness",
    name = "先祖迅捷 治疗链",
    description = "根据|cffb87ff0[被动卡]|r规则，血量<|cff6bc7e0{triggerPercent}%|r时施放",
    details = "根据|cffb87ff0[被动卡]|r规则，血量低于卡片设定值时施放先祖迅捷。未单独设置时使用默认值30%。需要存在有效目标。仅对友方存活目标生效。会检查战斗状态、距离、视野、相关生命值与技能可用性。",
    sort = 50,
    category = "class",
    exclusiveGroup = "shaman_ancestral_swiftness_followup",
    classes = {
        SHAMAN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_RavenForm",
        "Interface\\Icons\\Spell_Nature_HealingWaveGreater",
    },
    cooldown = { type = "spell", name = "先祖迅捷" },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发血量",
            unit = "%",
            default = 30,
            minimum = 1,
            maximum = 99,
        },
    },
}

function card.RefreshRuntimeData()
end

local function GetConfiguredRankRange(context)
    local minimumRank = 1
    local maximumRank = 3
    local steps = context and context.profile and context.profile.steps
    if not steps then
        return minimumRank, maximumRank
    end

    for _, followupStep in ipairs(steps) do
        if followupStep and followupStep.enabled ~= 0 and followupStep.id == "shaman_chain_heal" then
            minimumRank = context:GetStepOption(followupStep, "minimumRank") or minimumRank
            maximumRank = context:GetStepOption(followupStep, "maximumRank") or maximumRank
            break
        end
    end
    return minimumRank, maximumRank
end

function card.Health(unit, member, context, triggerPercent)
    local followupCard = Cat2.CardRegistry and Cat2.CardRegistry.ById["shaman_chain_heal"]
    if not followupCard or type(followupCard.CastOnUnit) ~= "function" then
        return false
    end

    Cat2.EnsureCardRuntimeData(followupCard)
    local minimumRank, maximumRank = GetConfiguredRankRange(context)
    local function ActivateAncestralSwiftness()
        if Cat2.GetChanneled() >= 0.08 or not Cat2.SpellReady("先祖迅捷") then
            return false
        end
        Cat2.Cast("先祖迅捷")
        return true
    end

    return followupCard.CastOnUnit(
        unit,
        member,
        context,
        triggerPercent,
        minimumRank,
        maximumRank,
        ActivateAncestralSwiftness
    ) == true
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 30

    if not player.inCombat then
        return false
    end
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

    -- 当前目标。
    local targetFirst = context.parameters and context.parameters.HealingTarget
    if targetFirst and player.targetExists then
        if card.Health("target", nil, context, triggerPercent) then
            return true
        end
    end

    -- 当前目标的目标。
    local targetTarget = context.parameters and context.parameters.HealingTargetTarget
    if targetTarget and player.targetExists and UnitExists("targettarget") then
        if card.Health("targettarget", nil, context, triggerPercent) then
            return true
        end
    end

    -- 玩家自己。
    local selfFirst = context.parameters and context.parameters.HealingSelf
    if selfFirst then
        if card.Health("player", nil, context, triggerPercent) then
            return true
        end
    end

    -- 小队成员，按血量从低到高扫描。
    local partyFirst = context.parameters and context.parameters.HealingParty
    if partyFirst then
        local sortedMembers = context:GetTeamMembers("party", "health")
        for _, member in ipairs(sortedMembers) do
            if card.Health(member.unit, member, context, triggerPercent) then
                return true
            end
        end
    end

    -- 小队或团队成员，随机扫描。
    local randomScanTeam = context.parameters and context.parameters.RandomHealingRaid
    if randomScanTeam then
        local sortedMembers = context:GetTeamMembers("group", "random")
        for _, member in ipairs(sortedMembers) do
            if card.Health(member.unit, member, context, triggerPercent) then
                return true
            end
        end
    end

    -- 小队或团队成员，按血量从低到高扫描。
    local scanTeam = context.parameters and context.parameters.HealingRaid
    if scanTeam then
        local sortedMembers = context:GetTeamMembers("group", "health")
        for _, member in ipairs(sortedMembers) do
            if card.Health(member.unit, member, context, triggerPercent) then
                return true
            end
        end
    end

    -- 小队或团队成员，优先扫描最大生命值较高的成员。
    local tankFirst = context.parameters and context.parameters.HealingTeamPriorityTank
    if tankFirst then
        local sortedMembers = context:GetTeamMembers("group", "maxHealth")
        for _, member in ipairs(sortedMembers) do
            if card.Health(member.unit, member, context, triggerPercent) then
                return true
            end
        end
    end
    return false
end

Cat2.RegisterCard(card)
