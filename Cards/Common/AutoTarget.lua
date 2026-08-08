-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "common_auto_target",
    -- 界面中显示的卡片标题。
    name = "自动锁敌",
    -- 卡片标题下方显示的简短说明。
    description = "选择近处敌对目标，且敌人在你正面。",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "选择近处敌对目标，且敌人在你正面。仅对可攻击目标生效。会检查目标距离。会检查与目标的相对位置。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 20,
    -- 仅能是 common、item、class 三种分类之一。
    category = "common",
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\Ability_Hunter_SniperShot",
    },
}

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end

-- 返回后续流程执行器读取的动作描述。
function card.Execute(context)

	local isClear = 0
	local target = UnitExists("target")

	-- 是否存在目标
	if not target then
		isClear = 1
	else

		-- 目标是否超出近战距离
		if target and not Cat2.TargetDistance() then
			if Cat2.ScanNearbyEnemies() > 0 then
				isClear = 1
			end
		end

		-- UnitXP存在，增加一个机制
		if Cat2.UnitXP and target then
			-- 目标在你背后
			if UnitXP("behind", "target", "player") then
				isClear = 1
			end
		end

		-- 目标是否可以攻击
		if not UnitCanAttack("player", "target") then
			ClearTarget()
			isClear = 1
		end

		-- 目标是否死亡
		if UnitIsDeadOrGhost("target") then
			ClearTarget()
			isClear = 1
		end

	end

    -- 如果当前目标不存在/已死亡/不可攻击
    if isClear==1 then
		TargetNearestEnemy()
    end

end

Cat2.RegisterCard(card)
