-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_reform",
    -- 界面中显示的卡片标题。
    name = "重整",
    -- 卡片标题下方显示的简短说明。
    description = "当条件满足时，能量<|cff6bc7e0{energyThreshold}|r，猛虎保护|cff6bc7e0{tigersFuryProtectionSeconds}|r秒，进行重整回能",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "能量低于卡片设定值、GCD低于0.3秒，且猛虎之怒经过设定的保护时间后施放重整。成功执行时会阻断本轮后续卡片。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 400,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    canStopSequence = true,
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        DRUID = 2,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\spell_reshift_2",
    },
    optionSchema = {
        {
            key = "energyThreshold",
            type = "number",
            label = "能量阈值",
            shortLabel = "能",
            default = 28,
            minimum = 0,
            maximum = 100,
        },
        {
            key = "tigersFuryProtectionSeconds",
            type = "number",
            label = "猛虎保护时间",
            shortLabel = "猛虎",
            unit = "秒",
            default = 3,
            minimum = 0,
            maximum = 16,
        },
    },
}

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end


function card.CheckShapeshift()

	local allow = 0

	-- 自动回能
	local restoredEnergyPosition = Cat2.DruidRestoredEnergy()
	if restoredEnergyPosition and restoredEnergyPosition<1.2 then
		allow = allow + 4
	end

	-- 猛虎回能
	if (Cat2.GetDruidTigerFuryTimer()-GetTime())>0.8 then
		allow = allow + 2
	end

	-- 扫击回能
	if (Cat2.GetDruidRateJumpTimer()-GetTime())>0.8 then
		allow = allow + 1
	end

	-- 撕扯回能
	if (Cat2.GetDruidRipJumpTimer()-GetTime())>0.8 then
		allow = allow + 1
	end

	return allow
end


-- 返回后续流程执行器读取的动作描述。
function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local energyThreshold = context:GetStepOption(step, "energyThreshold") or 28
    local tigersFuryProtectionSeconds = context:GetStepOption(step, "tigersFuryProtectionSeconds") or 3


    -- 保护猛虎
	if context:IsCardActive("druid_tigers_fury") and GetTime()-Cat2.DruidMHTimer>16 then
		if player.power<30 then
			Cat2.Cast("重整")
			return true
		end
	end


    if player.buff["节能施法"] or player.buff["狂暴"] then  -- or player.buff["阿莎曼之怒"] 
        return false
    end

    if player.gcd>0.3 then
        return false
    end

    -- 不吃流血
    if not player.targetBleed then
        if GetTime()-Cat2.DruidMHTimer>tigersFuryProtectionSeconds then
            local Restore = card.CheckShapeshift()
            if Restore>=4 and player.power<energyThreshold then
                Cat2.Cast("重整")
		        return true
            end
		    if player.power<10 then
			    Cat2.Cast("重整")
		        return true
		    end
        end
        return false
    end

    if GetTime()-Cat2.DruidMHTimer>tigersFuryProtectionSeconds then
        local Restore = card.CheckShapeshift()
        if Restore>=6 and player.power<energyThreshold then
            Cat2.Cast("重整")
		    return true
        end
		if Restore>=4 and player.power<10 then
			Cat2.Cast("重整")
		    return true
		end
    end

    return false
end

Cat2.RegisterCard(card)
