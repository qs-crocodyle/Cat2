-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "common_auto_target_distant",
    -- 界面中显示的卡片标题。
    name = "自动锁敌（最远敌人）",
    -- 卡片标题下方显示的简短说明。
    description = "选择远处敌对目标，朝向锥面，需UnitXP模组",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "选择远处敌对目标，朝向锥面，需UnitXP模组。仅对可攻击目标生效。会检查与目标的相对位置。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 21,
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

	if not Cat2.UnitXP then
		return
	end

	-- 当前有目标
	local t = UnitExists("target")
	if t then
		local dist = UnitXP("distanceBetween", "player", "target")
		if dist then

			if dist<8 or dist>41 then
				-- 无效距离
			else
				-- 有效距离，不切换
				return
			end
		end
	end

    local list = {}
    local count = 0

    _,count,_,list = Cat2.ScanNearbyEnemies()

    if count==0 then
        --pirnt("周围没有敌人")
        return
    end

	local farway = 0
	local target = nil

	for key, value in pairs(list) do
		local dist = UnitXP("distanceBetween", "player", key)

		-- 距离41码内
		if dist and dist<41 and dist > farway then

			-- 目标 1可以攻击 2未死亡 3已进入战斗 4排除小动物
			if UnitCanAttack("player", key) and not UnitIsDeadOrGhost(key) and UnitAffectingCombat(key) and UnitCreatureType(key) ~= "小动物" then

				-- 正面朝向
				if not UnitXP("behind", key, "player") then

					-- 视野中
					local inS = UnitXP("inSight", "player", key)
					if inS then
						farway = dist
						target = key
					end

				end
			end

		end
	end

	-- 选择扫描后目标
	if target~=nil then
		TargetUnit(target)
	end

end

Cat2.RegisterCard(card)
