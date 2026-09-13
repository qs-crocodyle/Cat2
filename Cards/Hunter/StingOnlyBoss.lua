-- 所有钉刺及分支共用的强敌限制；不阻断其他卡片。
local card = {
    id = "hunter_sting_only_boss",
    name = "钉刺 仅强敌时",
    description = "所有钉刺及分支仅对强敌目标施放",
    details = "启用后，毒蛇钉刺、毒蛇钉刺（剧毒弹药）、蝰蛇钉刺和毒蝎钉刺仅对强敌目标施放，沿用插件统一的强敌判定。普通目标直接跳过钉刺，继续后续卡片。被动效果不受本卡在流程中的位置影响；暂停或移除后恢复原有逻辑。",
    sort = 80.1,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = { HUNTER = 2 },
    icons = {
        "Interface\\Icons\\Ability_Hunter_Quickshot",
        "Interface\\Icons\\Ability_Hunter_AimedShot",
        "Interface\\Icons\\Ability_Hunter_CriticalShot",
    },
}

function card.RefreshRuntimeData()
end

function card.Apply(context)
    context.parameters.hunterStingOnlyBoss = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
