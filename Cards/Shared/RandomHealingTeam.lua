-- 随机治疗团队共享被动卡。
-- 为兼容已保存流程，旧 ID shared_healing_raid 会在 Persistence.lua 中迁移到本卡。
local card = {
    id = "shared_random_healing_team",
    name = "治疗团队 随机",
    description = "治疗团队成员，随机选择一个有掉血的成员",
    details = "治疗团队成员，随机选择一个有掉血的成员。作为被动规则，启用时影响当前流程。",
    sort = 445,
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
        "Interface\\Icons\\INV_Glyph_MajorShaman",
    },
}

function card.RefreshRuntimeData()
end

function card.Apply(context)
    context.parameters.RandomHealingRaid = 1
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
