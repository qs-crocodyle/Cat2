-- 双刃毒袭 技能卡片。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "rogue_dual_blade_poison_strike",
    -- 界面中显示的卡片标题。
    name = "双刃毒袭",
    -- 卡片标题下方显示的简短说明。
    description = "45能量时施放双刃毒袭",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "45能量时施放双刃毒袭。需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 10,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    canStopSequence = true,
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        ROGUE = 1,
    },
    -- 默认使用问号图标；登录后会优先从技能书读取同名技能的真实图标。
    icons = {
        "Interface\\Icons\\spell_double_dose_3",
    },
}


local allowUse = 0

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,18)
end

-- 当前目标存在且能量满足门槛时施放，并终止本轮后续流程。
function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    if player.power >= 45 then
        CastSpellByName("双刃毒袭")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
