-- 治疗团队 优先坦克 被动卡片。
--
-- 这是团队治疗的优先级参数。它可与“治疗团队”共同启用，
-- 由后续接入该参数的治疗技能优先选择坦克目标。
local card = {
    id = "shared_healing_team_priority_tank",
    name = "治疗团队 优先坦克（待测试）",
    description = "治疗团队成员，优先总血量，通常坦的总血量最高",
    details = "治疗团队成员，优先总血量，通常坦的总血量最高。作为被动规则，启用时影响当前流程。",
    sort = 444.6,
    behavior = "passive",
    unique = true,
    -- 与“治疗团队”互斥，同一流程只保留一种团队治疗策略。
    exclusiveGroup = "shared_healing_team_mode",
    category = "class",
    classes = {
        DRUID = 3,
        SHAMAN = 3,
        PALADIN = 1,
        PRIEST = 2,
    },
    icons = {
        "Interface\\Icons\\INV_Glyph_MajorPriest",
    },
}

-- 初始化入口：预留给后续团队目标缓存或事件注册。
function card.RefreshRuntimeData()
end

-- 被动卡在本轮普通卡片执行前写入共享参数。
function card.Apply(context)
    context.parameters.HealingTeamPriorityTank = 1
end

-- 当前策略本身不阻止流程执行。
function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
