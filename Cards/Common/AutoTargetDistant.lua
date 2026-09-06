-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "common_auto_target_distant",
    -- 界面中显示的卡片标题。
    name = "自动锁敌（最远敌人）",
    -- 卡片标题下方显示的简短说明。
    description = "选择远处敌对目标，朝向锥面，需UnitXP模组",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "选择8～41码内最远的正面敌对目标。仅对可攻击、存活的非小动物目标生效；启用“自动锁敌 忽略 未进战斗目标”后还会排除尚未进入战斗的目标。死亡目标会被放弃；其他情况下没有合格替代目标时保留当前目标。切换或清除目标后会立即刷新角色数据并继续本轮流程。无SuperWoW时无法扫描敌人，本卡不会自动锁敌。",
    -- 自动锁敌策略互斥；同一流程中只允许启用一种。
    exclusiveGroup = "common_auto_target",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 23,
    -- 仅能是 common、item、class 三种分类之一。
    category = "common",
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\Ability_Hunter_SniperShot",
    },
}

-- 各张自动锁敌卡分别计时；这里只限制本卡进入锁敌逻辑的频率。
local EXECUTION_INTERVAL = 0.2
local nextExecutionTime = 0

local function RefreshPlayerDataAfterTargetChange()
	if Cat2.RefreshPlayerTemporaryInformation then
		Cat2.RefreshPlayerTemporaryInformation()
	end
end

-- 当前目标与扫描候选统一使用同一套战斗属性规则。
local function IsValidEnemy(unit, context)
	return UnitCanAttack("player", unit)
		and not UnitIsDeadOrGhost(unit)
		and Cat2.IsAutoTargetCandidateAllowed(unit, context)
		and UnitCreatureType(unit) ~= "小动物"
end

-- 几何条件统一限定为8码外、41码内、角色正面且处于视野中。
local function GetValidEnemyDistance(unit, context)
	if not IsValidEnemy(unit, context) then
		return nil
	end

	local dist = UnitXP("distanceBetween", "player", unit)
	if not dist or dist <= 8 or dist >= 41 then
		return nil
	end
	if UnitXP("behind", unit, "player") or not UnitXP("inSight", "player", unit) then
		return nil
	end
	return dist
end

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end

-- 返回后续流程执行器读取的动作描述。
function card.Execute(context)

	local currentTime = GetTime()
	if currentTime < nextExecutionTime then
		return false
	end
	nextExecutionTime = currentTime + EXECUTION_INTERVAL

    local player = Cat2.PlayerInformation.temporary

	if not Cat2.UnitXP or not Cat2.SuperWoW then
		if player.targetExists and UnitIsDeadOrGhost("target") then
			ClearTarget()
			RefreshPlayerDataAfterTargetChange()
		end
		return false
	end

	-- 已有目标完全符合规则时保持目标，并允许后续卡片正常执行。
	if player.targetExists and GetValidEnemyDistance("target", context) then
		return false
	end

    local list = {}
    local count = 0

	count,_,list,_ = Cat2.ScanNearbyEnemies(41)

    if count==0 then
        -- 当前目标不合格但没有替代目标时，保留玩家当前选择并继续本轮。
        if player.targetExists then
            if UnitIsDeadOrGhost("target") then
                ClearTarget()
                RefreshPlayerDataAfterTargetChange()
            end
            return false
        end
        return false
    end

	local farway = 8
	local target = nil

	for key, value in pairs(list) do

		local dist = GetValidEnemyDistance(key, context)
		if dist and dist > farway then
			farway = dist
			target = key
		end

	end

	-- 选择扫描后目标
	-- 切换前再次检查，避免选中扫描完成后刚死亡的候选单位。
	if target~=nil and not UnitIsDeadOrGhost(target) then
		local oldTargetExists, oldTargetGUID = UnitExists("target")
		TargetUnit(target)
		local newTargetExists, newTargetGUID = UnitExists("target")
		if newTargetExists and newTargetGUID ~= oldTargetGUID and GetValidEnemyDistance("target", context) then
			RefreshPlayerDataAfterTargetChange()
			return false
		end
		-- TargetUnit可能因候选失效而静默失败；未确认切换时恢复原目标。
		if oldTargetExists and oldTargetGUID then
			TargetUnit(oldTargetGUID)
		elseif newTargetExists then
			ClearTarget()
		end
	end

	-- 当前目标不合格且没有替代目标时保留选择，并允许后续卡片执行。
	if player.targetExists then
		if UnitIsDeadOrGhost("target") then
			ClearTarget()
			RefreshPlayerDataAfterTargetChange()
		end
		return false
	end

	return false
end

Cat2.RegisterCard(card)
