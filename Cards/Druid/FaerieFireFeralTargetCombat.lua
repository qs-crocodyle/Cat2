-- 精灵之火（野性）（仅目标战斗）被动规则。
local card = {
    id = "druid_faerie_fire_feral_target_combat",
    name = "精灵之火（野性）（仅对战斗中目标）",
    description = "两张野性精灵之火仅对战斗中的目标生效",
    details = "启用后，精灵之火（野性）与精灵之火（野性）（清晰预兆）仅在目标已进入战斗时执行。作为被动规则，启用时影响当前流程。",
    sort = 142,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        DRUID = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_FaerieFire",
    },
}

function card.RefreshRuntimeData()
end

-- 被动卡先于普通卡应用，因此不依赖在流程中的排列位置。
function card.Apply(context)
    context.parameters.faerieFireFeralTargetCombatOnly = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
