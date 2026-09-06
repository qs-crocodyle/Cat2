-- 撕扯仅对强敌生效的被动标记卡片。
local card = {
    id = "druid_rip_only_boss",
    name = "撕扯 仅强敌时",
    description = "撕扯仅对强敌目标生效",
    details = "启用后，一至五星的撕扯仅对带有强敌标记的目标生效，普通目标会被忽略。该卡片只写入流程标记，不会主动施放技能。作为被动规则，启用时影响当前流程。",
    sort = 430,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        DRUID = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_GhoulFrenzy",
    },
}

function card.RefreshRuntimeData()
end

function card.Apply(context)
    context.parameters.druidRipOnlyBoss = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
