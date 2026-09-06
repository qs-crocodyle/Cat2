-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "item_major_healing_potion",
    -- 界面中显示的卡片标题。
    name = "特效治疗药水",
    -- 卡片标题下方显示的简短说明。
    description = "血量低于|cff6bc7e0{triggerPercent}%|r时使用特效治疗药水",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "战斗中血量低于卡片设定值时，使用特效治疗药水。未单独设置时使用默认值30%。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 50,
    -- 仅能是 common、item、class 三种分类之一。
    category = "item",
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\INV_Potion_54",
    },
    cooldown = {
        type = "item",
        name = "特效治疗药水",
    },
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

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end

-- 返回后续流程执行器读取的动作描述。
function card.Execute(context, step)

    local percent = context:GetStepOption(step, "triggerPercent") or 30
    local player = Cat2.PlayerInformation.temporary

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end

    if player.inCombat and player.percentHealth<percent then
		Cat2.UseItemByName("特效治疗药水")
    end
end

Cat2.RegisterCard(card)
