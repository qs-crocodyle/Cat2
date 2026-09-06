-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_moonkin_form",
    -- 界面中显示的卡片标题。
    name = "枭兽形态",
    -- 卡片标题下方显示的简短说明。
    description = "切换并保持至枭兽形态",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "切换并保持至枭兽形态。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 9,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        DRUID = 1,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\Spell_Nature_ForceOfNature",
    },
}

local allowUse = 0
local ShapeshiftID = 0

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()

    allowUse = Cat2.IsTalentLearned(1,20)

	for i = 1, 9 do
		local _, name, _, id = GetShapeshiftFormInfo(i)
        if name then
            if name=="枭兽形态" then
                ShapeshiftID = i
                return
            end
        end
	end
end

-- 返回后续流程执行器读取的动作描述。
function card.Execute(context)

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    if ShapeshiftID > 0 then

		if not Cat2.GetShape(ShapeshiftID) then
			CastShapeshiftForm(ShapeshiftID)
			return true
		end

    else

        if not Cat2.PlayerInformation.temporary.buff["枭兽形态"] then
            Cat2.Cast("枭兽形态")
		    return true
        end

    end

    return false
end

Cat2.RegisterCard(card)
