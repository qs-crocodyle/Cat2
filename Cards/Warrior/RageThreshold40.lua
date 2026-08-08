-- 为狂暴系流程提供 40 点怒气阈值的被动卡片。
local card = {
    id = "warrior_rage_threshold_40",
    name = "怒气阈值 >40",
    description = "修改英勇打击/顺劈斩为>40点怒气",
    details = "修改英勇打击/顺劈斩为>40点怒气。作为被动规则，启用时影响当前流程。",
    sort = 93,
    behavior = "passive",
    unique = true,
    exclusiveGroup = "warrior_rage_threshold",
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_CurseOfTounges",
    },
}

function card.RefreshRuntimeData()
end

function card.Apply(context)
    context.parameters.warriorRageThreshold = 40
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
