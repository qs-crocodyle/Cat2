-- 治疗团队共享被动卡。
-- 当前复用“随机治疗团队”的参数开关，供各职业治疗卡进入团队成员治疗分支。
local card = {
    id = "shared_healing_team",
    name = "治疗团队 血线最低",
    description = "治疗团队成员，优先选择血线最低",
    details = "治疗团队成员，优先选择血线最低。作为被动规则，启用时影响当前流程。",
    sort = 444.5,
    behavior = "passive",
    unique = true,
    -- 与“随机治疗团队”互斥，同一流程只保留一种团队治疗策略。
    exclusiveGroup = "shared_healing_team_mode",
    category = "class",
    classes = {
        DRUID = 3,
        SHAMAN = 3,
        PALADIN = 1,
        PRIEST = 2,
    },
    icons = {
        "Interface\\Icons\\INV_Glyph_MajorWarlock",
    },
}

function card.RefreshRuntimeData()
end

function card.Apply(context)
    -- 治疗技能当前读取 HealingRaid 开关，并在团队成员中执行既有选择逻辑。
    context.parameters.HealingRaid = 1
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
