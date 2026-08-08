-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_ferocious_bite5_50",
    -- 界面中显示的卡片标题。
    name = "凶猛撕咬（五星，能量<50）",
    -- 卡片标题下方显示的简短说明。
    description = "消耗5连击点造成终结伤害，能量<50",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "消耗5连击点造成终结伤害，能量<50。需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
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
}

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end

-- 返回后续流程执行器读取的动作描述。
function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end


    local energyLimit = context and context.parameters and context.parameters.ferociousBiteEnergyLimit or 50
    if (player.power>=35 or player.buff["节能施法"]) and player.power<energyLimit and player.targetCombo==5 then
        CastSpellByName("凶猛撕咬")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
