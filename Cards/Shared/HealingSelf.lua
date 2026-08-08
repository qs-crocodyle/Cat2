-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "shared_healing_self",
    -- 界面中显示的卡片标题。
    name = "优先自己",
    -- 卡片标题下方显示的简短说明。
    description = "治疗技能策略，优先治疗自己",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "治疗技能策略，优先治疗自己。作为被动规则，启用时影响当前流程。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 446,
    behavior = "passive",
    unique = true,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    -- 同一张卡在不同职业中归入各自对应的治疗天赋系。
    classes = {
        DRUID = 3,
        SHAMAN = 3,
        PALADIN = 1,
        PRIEST = 2,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\INV_Glyph_MinorWarrior",
    },
}

function card.RefreshRuntimeData()
end

-- 所有启用的被动卡片会在普通卡片执行前调用 Apply，排列位置不影响作用范围。
function card.Apply(context)
    context.parameters.HealingSelf = 1
end

-- 返回 false 可阻止整条流程
function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
