-- 扫击仅对强敌生效的被动标记卡片。
local card = {
    id = "druid_rake_only_boss",
    name = "扫击 仅强敌时",
    description = "扫击仅对强敌目标生效",
    details = "启用后，扫击仅对带有强敌标记的目标生效，普通目标会被忽略。该卡片只写入流程标记，不会主动施放技能。作为被动规则，启用时影响当前流程。",
    sort = 412,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        DRUID = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Druid_Disembowel",
    },
}

function card.RefreshRuntimeData()
end

function card.Apply(context)
    context.parameters.druidRakeOnlyBoss = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
