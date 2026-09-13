-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_ferocious_bite_emergency_refill",
    -- 界面中显示的卡片标题。
    name = "凶猛撕咬（紧急续杯）",
    -- 卡片标题下方显示的简短说明。
    description = "流血即将消失时施放凶猛撕咬",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "流血即将消失时施放凶猛撕咬，这是个补救措施。需要SuperWoW模组，需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 440.1,
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

    if Cat2.GetRipDot() and not Cat2.GetRipDot("target", 2) then
    
        if player.targetCombo>0 and (player.power>=35 or player.buff["节能施法"]) then
            Cat2.Cast("凶猛撕咬")
            print(Cat2.L("凶猛撕咬（紧急续杯）"))
            return true
        end

    end

    return false
end

Cat2.RegisterCard(card)
