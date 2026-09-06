-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_ferocious_bite5_50",
    -- 界面中显示的卡片标题。
    name = "凶猛撕咬（五星）",
    -- 卡片标题下方显示的简短说明。
    description = "能量低于|cff6bc7e0{energyLimit}|r时施放凶猛撕咬",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "能量低于卡片设定值时，按本卡片对应的连击点施放凶猛撕咬。需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 440,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    canStopSequence = true,
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        DRUID = 2,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\Ability_Druid_FerociousBite",
    },
    optionSchema = {
        {
            key = "energyLimit",
            type = "number",
            label = "能量上限",
            shortLabel = "能",
            default = 50,
            minimum = 36,
            maximum = 100,
        },
    },
}

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end

-- 返回后续流程执行器读取的动作描述。
function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end


    if player.buff["节能施法"] then
    
        if player.power<28 and player.targetCombo==5 then
            Cat2.Cast("凶猛撕咬")
            return true
        end

    else

        local energyLimit = context:GetStepOption(step, "energyLimit") or 50
        if player.power>=35 and player.power<energyLimit and player.targetCombo==5 then
            Cat2.Cast("凶猛撕咬")
            return true
        end

    end

    return false
end

Cat2.RegisterCard(card)
