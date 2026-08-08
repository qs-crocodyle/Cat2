-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_rip_lowHP",
    -- 界面中显示的卡片标题。
    name = "撕扯 低血量忽略",
    -- 卡片标题下方显示的简短说明。
    description = "目标 血量<3000 不打撕扯",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "目标 血量<3000 不打撕扯。作为被动规则，启用时影响当前流程。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 429,
    behavior = "passive",
    unique = true,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        DRUID = 2,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\Ability_GhoulFrenzy",
    },
}

function card.RefreshRuntimeData()
end

-- 所有启用的被动卡片会在普通卡片执行前调用 Apply，排列位置不影响作用范围。
function card.Apply(context)
    context.parameters.ripHP = 3000
end

-- 返回 false 可阻止整条流程
function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
