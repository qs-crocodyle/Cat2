-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_regrowth",
    -- 界面中显示的卡片标题。
    name = "愈合",
    -- 卡片标题下方显示的简短说明。
    description = "根据|cffb87ff0[被动卡]|r规则，自适配等级施放治疗并附加持续治疗",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "根据|cffb87ff0[被动卡]|r规则，自适配等级施放治疗并附加持续治疗。需要存在有效目标。仅对可攻击目标生效。会检查相关生命值。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 220,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        DRUID = 3,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\Spell_Nature_ResistNature",
    },
}


-- 愈合参数
local DruidRegrowth = {}
local DruidRegrowthEffect = {}
local DruidRegrowthFactor = 0.4
local DruidRegrowthMaxLevel = 9

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

	-- 只有在树形态才有耗蓝减少
	if Cat2.IsTalentLearned(3,16)==1 then
		percent = percent - 0.2
	end

	-- 天赋-宁静之魂，该天赋只对愈合、触有效
	percent = percent - Cat2.IsTalentLearned(3,10)*0.02


    local HealingPower = Cat2.CalculateTotalHealingPower()

    DruidRegrowth[1] = math.floor( 96 * percent )
    DruidRegrowthEffect[1] = 100+(HealingPower*DruidRegrowthFactor)
    DruidRegrowth[2] = math.floor( 164 * percent )
    DruidRegrowthEffect[2] = 188+(HealingPower*DruidRegrowthFactor)
    DruidRegrowth[3] = math.floor( 224 * percent )
    DruidRegrowthEffect[3] = 272+(HealingPower*DruidRegrowthFactor)
    DruidRegrowth[4] = math.floor( 280 * percent )
    DruidRegrowthEffect[4] = 357+(HealingPower*DruidRegrowthFactor)
    DruidRegrowth[5] = math.floor( 336 * percent )
    DruidRegrowthEffect[5] = 451+(HealingPower*DruidRegrowthFactor)
    DruidRegrowth[6] = math.floor( 408 * percent )
    DruidRegrowthEffect[6] = 566+(HealingPower*DruidRegrowthFactor)
    DruidRegrowth[7] = math.floor( 492 * percent )
    DruidRegrowthEffect[7] = 711+(HealingPower*DruidRegrowthFactor)
    DruidRegrowth[8] = math.floor( 592 * percent )
    DruidRegrowthEffect[8] = 887+(HealingPower*DruidRegrowthFactor)
    DruidRegrowth[9] = math.floor( 704 * percent )
    DruidRegrowthEffect[9] = 1061+(HealingPower*DruidRegrowthFactor)

    DruidRegrowthMaxLevel = Cat2.GetHighestRankOfSpell("愈合")

end


local HealTargetDelay = {}
local HundredFlower = 0

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

    -- 目标是否已经有愈合
    if Cat2.Buff("愈合",unit) then
        -- 百花齐放
        if HundredFlower==1 then
            local percentHealth = health/maxHealth * 100
            if percentHealth > 79.9 then
                return false
            end
        else
            return false
        end
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

    -- 读愈合

    -- 先确保技能已学
    if DruidRegrowthMaxLevel>0 then

        -- 根据配置等级和所学等级计算
        for i = DruidRegrowthMaxLevel, 1, -1 do
            if DruidRegrowthEffect[i] < HealthDec then

                if Cat2.PlayerInformation.temporary.mana >= DruidRegrowth[i] then
                    return Cat2.CastSpellWithoutTarget("愈合(等级 "..i..")", unit, 1)
                else
                    return Cat2.CastSpellWithoutTarget("愈合(等级 1)", unit, 1)
                end

            end
        end

        return Cat2.CastSpellWithoutTarget("愈合(等级 1)", unit, 1)

    end


    return false
end



-- 返回后续流程执行器读取的动作描述。
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

    -- 百花齐放
    HundredFlower = context and context.parameters and context.parameters.flowers
    if not HundredFlower then
        HundredFlower = 0
    end


    -- 目标
    local TargetFirst = context and context.parameters and context.parameters.HealingTarget
    if TargetFirst and player.targetExists then
        if card.Health("target") then
            return
        end
    end

    -- 目标 的 目标
    local TargetTarget = context and context.parameters and context.parameters.HealingTargetTarget
    if TargetTarget and player.targetExists and UnitExists("targettarget") then
        if card.Health("targettarget") then
            return
        end
    end

    -- 自己
    local SelfFirst = context and context.parameters and context.parameters.HealingSelf
    if SelfFirst then
        if card.Health("player") then
            return
        end
    end

    -- 小队成员
    local PartyFirst = context and context.parameters and context.parameters.HealingParty
    if PartyFirst then
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
