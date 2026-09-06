-- 参数型治疗卡参考：optionSchema 属于卡片定义，具体 optionValues 属于每个流程 step。
-- castProfile 只声明该技能支持哪些能力，是否启用满血中断由共享被动策略决定。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_healing_touch_target",
    -- 界面中显示的卡片标题。
    name = "治疗之触",
    -- 卡片标题下方显示的简短说明。
    description = "根据|cffb87ff0[被动卡]|r规则，血量<|cff6bc7e0{triggerPercent}%|r时自适配等级施放",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "根据|cffb87ff0[被动卡]|r规则，血量低于卡片设定值时，在设定等级区间内自适配等级进行治疗。默认触发血量为99%。需要存在有效目标。仅对可攻击目标生效。会检查相关生命值。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 200,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        DRUID = 3,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\Spell_Nature_HealingTouch",
    },
    castProfile = {
        spellNames = {
            "治疗之触",
        },
        tags = {
            healing = true,
            singleTarget = true,
            fullHealthCancelable = true,
        },
    },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发血量",
            unit = "%",
            default = 99,
            minimum = 1,
            maximum = 99,
        },
        {
            key = "minimumRank",
            type = "number",
            label = "最小等级",
            default = 1,
            minimum = 1,
            maximum = 11,
        },
        {
            key = "maximumRank",
            type = "number",
            label = "最大等级",
            default = 11,
            minimum = 1,
            maximum = 11,
        },
    },
}

-- 治疗之触参数
local DruidHealingTouch = {}
local DruidHealingTouchEffect = {}
local DruidHealingTouchFactor = 0.2
local DruidHealingTouchMaxLevel = 11


-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()

	-- 奶德T3套装特效
	local count = 0
	local percent = 1
	if Cat2.CheckInventoryItemName(1,"梦游者头饰") then count=count+1 end
	if Cat2.CheckInventoryItemName(3,"梦游者肩饰") then count=count+1 end
	if Cat2.CheckInventoryItemName(5,"梦游者外套") then count=count+1 end
	if Cat2.CheckInventoryItemName(6,"梦游者束带") then count=count+1 end
	if Cat2.CheckInventoryItemName(7,"梦游者护腿") then count=count+1 end
	if Cat2.CheckInventoryItemName(8,"梦游者长靴") then count=count+1 end
	if Cat2.CheckInventoryItemName(9,"梦游者腕甲") then count=count+1 end
	if Cat2.CheckInventoryItemName(10,"梦游者护手") then count=count+1 end
	if Cat2.CheckInventoryItemName(11,"梦游者之戒") then count=count+1 end
	if Cat2.CheckInventoryItemName(12,"梦游者之戒") then count=count+1 end
	if count >= 4 then
		percent = percent - 0.03
	end

	-- 天赋-月光
	percent = percent - Cat2.IsTalentLearned(1,13)*0.03

	-- 天赋-宁静之魂，该天赋只对愈合、触有效
	percent = percent - Cat2.IsTalentLearned(3,10)*0.02

    local HealingPower = Cat2.CalculateTotalHealingPower()
    -- 治疗之触
    DruidHealingTouch[1] = 25 * percent
    DruidHealingTouchEffect[1] = 48+(HealingPower*DruidHealingTouchFactor)
    DruidHealingTouch[2] = 55 * percent
    DruidHealingTouchEffect[2] = 108+(HealingPower*DruidHealingTouchFactor)
    DruidHealingTouch[3] = 110 * percent
    DruidHealingTouchEffect[3] = 230+(HealingPower*DruidHealingTouchFactor)
    DruidHealingTouch[4] = 185 * percent
    DruidHealingTouchEffect[4] = 420+(HealingPower*DruidHealingTouchFactor)
    DruidHealingTouch[5] = 270 * percent
    DruidHealingTouchEffect[5] = 650+(HealingPower*DruidHealingTouchFactor)
    DruidHealingTouch[6] = 335 * percent
    DruidHealingTouchEffect[6] = 840+(HealingPower*DruidHealingTouchFactor)
    DruidHealingTouch[7] = 405 * percent
    DruidHealingTouchEffect[7] = 1050+(HealingPower*DruidHealingTouchFactor)
    DruidHealingTouch[8] = 495 * percent
    DruidHealingTouchEffect[8] = 1340+(HealingPower*DruidHealingTouchFactor)
    DruidHealingTouch[9] = 600 * percent
    DruidHealingTouchEffect[9] = 1630+(HealingPower*DruidHealingTouchFactor)
    DruidHealingTouch[10] = 720 * percent
    DruidHealingTouchEffect[10] = 2100+(HealingPower*DruidHealingTouchFactor)
    DruidHealingTouch[11] = 800 * percent
    DruidHealingTouchEffect[11] = 2450+(HealingPower*DruidHealingTouchFactor)

    DruidHealingTouchMaxLevel = Cat2.GetHighestRankOfSpell("治疗之触")

end

local HealTargetDelay = {}

local function NormalizeRankRange(minimumRank, maximumRank)
    if DruidHealingTouchMaxLevel <= 0 then
        return nil, nil
    end

    minimumRank = math.floor(tonumber(minimumRank) or 1)
    maximumRank = math.floor(tonumber(maximumRank) or 11)
    minimumRank = math.max(1, math.min(minimumRank, DruidHealingTouchMaxLevel))
    maximumRank = math.max(1, math.min(maximumRank, DruidHealingTouchMaxLevel))
    if minimumRank > maximumRank then
        minimumRank, maximumRank = maximumRank, minimumRank
    end
    return minimumRank, maximumRank
end

-- 验证完成后对指定单位施法。beforeCast 用于自然迅捷这类前置技能，
-- 只有治疗之触已学习、等级有效且法力足够时才会调用，避免提前消耗冷却。
function card.CastOnUnit(unit, member, context, triggerPercent, minimumRank, maximumRank, beforeCast)

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

    local percentHealth = health / maxHealth * 100
    if percentHealth >= triggerPercent then
        return false
    end

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

    minimumRank, maximumRank = NormalizeRankRange(minimumRank, maximumRank)
    if not minimumRank then
        return false
    end

    local mana = Cat2.PlayerInformation.temporary.mana
    local selectedRank
    for i = maximumRank, minimumRank, -1 do
        if DruidHealingTouchEffect[i] < HealthDec and mana >= DruidHealingTouch[i] then
            selectedRank = i
            break
        end
    end
    if not selectedRank and mana >= DruidHealingTouch[minimumRank] then
        selectedRank = minimumRank
    end
    if not selectedRank then
        return false
    end

    local spellName = "治疗之触(等级 "..selectedRank..")"
    if type(beforeCast) == "function" and beforeCast(unit, member, spellName) ~= true then
        return false
    end

    if targetName then
        HealTargetDelay[targetName] = GetTime()+1.0
    end
    return Cat2.CastSpellWithoutTarget(spellName, unit, 1)
end

function card.Health(unit, member, context, triggerPercent, minimumRank, maximumRank)
    return card.CastOnUnit(unit, member, context, triggerPercent, minimumRank, maximumRank)
end

-- 返回后续流程执行器读取的动作描述。
function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 99
    local minimumRank = context:GetStepOption(step, "minimumRank") or 1
    local maximumRank = context:GetStepOption(step, "maximumRank") or 11

    -- 不允许参数越过角色实际已学等级；填反区间时自动交换为有效范围。
    if maximumRank > DruidHealingTouchMaxLevel then
        maximumRank = DruidHealingTouchMaxLevel
    end
    if minimumRank > DruidHealingTouchMaxLevel then
        minimumRank = DruidHealingTouchMaxLevel
    end
    if minimumRank > maximumRank then
        minimumRank, maximumRank = maximumRank, minimumRank
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
