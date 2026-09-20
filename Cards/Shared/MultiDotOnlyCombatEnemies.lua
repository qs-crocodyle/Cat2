-- 跨职业多线 DOT 战斗目标规则；保留已发布的卡片 ID，兼容旧配置。
local card = {
    id = "warlock_multi_dot_only_combat_enemies",
    name = "多线DOT 仅战斗中敌人",
    description = "多线DOT仅对处于战斗中的敌人施放",
    details = "启用后，当前流程中接入此规则的多线DOT卡片只会选择已处于战斗中的敌人；未进入战斗的附近敌人会被忽略。适用于术士和牧师，不影响普通单目标DOT卡片。作为被动规则，不受本卡在流程中的排列位置影响。",
    sort = 158,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        WARLOCK = 1,
        PRIEST = 3,
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
    context.parameters.multiDotOnlyCombatEnemies = true
    -- 兼容现有术士多线卡；新职业卡使用上面的通用参数。
    context.parameters.warlockMultiDotOnlyCombatEnemies = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
