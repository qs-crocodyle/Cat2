-- 突袭 技能卡片。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "rogue_rush",
    -- 界面中显示的卡片标题。
    name = "突袭",
    -- 卡片标题下方显示的简短说明。
    description = "目标闪避且能量低于|cff6bc7e0{energyLimit}|r时，施放突袭",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "目标闪避且当前能量低于卡片设定上限时，施放突袭。需要存在有效目标，且至少拥有10点能量。成功执行时会阻断本轮后续卡片。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 35,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        ROGUE = 2,
    },
    -- 默认使用问号图标；登录后会优先从技能书读取同名技能的真实图标。
    icons = {
        "Interface\\Icons\\Ability_Rogue_SurpriseAttack",
    },
    optionSchema = {
        {
            key = "energyLimit",
            type = "number",
            label = "能量上限",
            shortLabel = "能",
            unit = "能量",
            default = 100,
            minimum = 11,
            maximum = 100,
        },
    },
}

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end

-- 预留卡片功能入口；后续可在此加入突袭的施放条件与动作。
function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local energyLimit = context:GetStepOption(step, "energyLimit") or 100

    if not player.targetExists then
        return false
    end

    if player.power >= 10 and player.power < energyLimit and Cat2.RogueSurpriseStrike() then
        Cat2.Cast("突袭")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
