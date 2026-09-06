-- 术士多线 DOT 仅对战斗中敌人生效的被动卡片。
local card = {
    id = "warlock_multi_dot_only_combat_enemies",
    name = "多线DOT 仅战斗中敌人",
    description = "多线DOT仅对处于战斗中的敌人施放",
    details = "启用后，术士的多线DOT卡片只会选择已处于战斗中的敌人；未进入战斗的附近敌人会被忽略。作为被动规则，启用时影响当前流程中的所有术士多线DOT卡片。",
    sort = 158,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Flare",
        "Interface\\Icons\\Ability_DualWield",
    },
}

function card.RefreshRuntimeData()
end

-- 被动卡先于普通卡片应用，因此不受自身在流程中的排列位置影响。
function card.Apply(context)
    context.parameters.warlockMultiDotOnlyCombatEnemies = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
