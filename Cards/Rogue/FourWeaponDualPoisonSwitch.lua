-- 四武器双毒切换：预留给四套武器与双毒切换逻辑。
-- 当前仅注册卡片数据和函数入口，具体功能由后续自行补充。
local card = {
    -- 稳定唯一标识；配置保存、导入和导出均依赖此 ID。
    id = "rogue_four_weapon_dual_poison_switch",

    -- 主界面右侧技能列表及流程卡片中显示的名称。
    name = "四武器双毒切换",

    -- 卡片标题下方显示的简短说明。
    description = "切换四武器，【双溶解】与【双速效】切换",

    -- 预留给详情提示使用的完整说明。
    details = "预留四武器，根据目标类型进行切换，仅支持【双溶解】与【双速效】切换，需要你预先把背包里的备用武器上好毒。切换检查间隔为0.1秒。",

    -- 位于双刃毒袭之后、致命投掷之前。
    sort = 10.5,

    category = "class",
    classes = {
        ROGUE = 1,
    },

    -- 暂用双持武器图标；以后可直接替换此纹理路径。
    icons = {
        "Interface\\Icons\\INV_Potion_19",
    },
}

-- 限制背包 Tooltip 扫描和换装频率，给前一次武器切换留出至少0.1秒更新时间。
local EXECUTION_INTERVAL = 0.1
local nextExecutionTime = 0

-- 卡片首次参与流程，以及技能、装备或天赋变化后再次参与流程时调用。
-- 当前没有需要缓存的运行时数据。
function card.RefreshRuntimeData()
end

-- 卡片功能入口。
-- 当前为空逻辑；返回 false 表示不阻断本轮后续卡片。
function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 确保没有跟NPC正在交互
    if Cat2.CheckUIStatus() then
        return false
    end

	-- 玩家继续按宏时，每0.1秒最多进入一次换武器逻辑。
	local currentTime = GetTime()
	if currentTime < nextExecutionTime then
		return false
	end
	nextExecutionTime = currentTime + EXECUTION_INTERVAL

	-- 目标刚建立时生物类型可能暂时为空；等待后续按键刷新，不能误判为普通生物。
	if not player.targetCreatureType then
		return false
	end

	local postion_text = ""
	local position = string.find("元素生物,机械,巨人,亡灵", player.targetCreatureType, 1, true)
	if position then
		-- 切换至溶解毒药
		-- 主手
		postion_text = Cat2.GetMainHandPostion()
		if not postion_text or not string.find( postion_text, "溶解毒药" ) then
			Cat2.RogueSwitchWeapon("溶解毒药", 16)
		else

			-- 副手
			postion_text = Cat2.GetOffHandPostion()
			if not postion_text or not string.find( postion_text, "溶解毒药" ) then
				Cat2.RogueSwitchWeapon("溶解毒药", 17)
			end
		end
	else
		-- 切换至速效毒药

		-- 主手
		postion_text = Cat2.GetMainHandPostion()
		if not postion_text or not string.find( postion_text, "速效毒药" ) then
			Cat2.RogueSwitchWeapon("速效毒药", 16)
		else

			-- 副手
			postion_text = Cat2.GetOffHandPostion()
			if not postion_text or not string.find( postion_text, "速效毒药" ) then
				Cat2.RogueSwitchWeapon("速效毒药", 17)
			end
		end
	end

    return false

end

Cat2.RegisterCard(card)
