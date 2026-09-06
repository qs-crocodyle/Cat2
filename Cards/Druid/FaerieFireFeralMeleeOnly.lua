-- 精灵之火（野性）（仅近战距离）被动规则。
local card = {
    id = "druid_faerie_fire_feral_melee_only",
    name = "精灵之火（野性）（仅近战距离）",
    description = "两张野性精灵之火仅在近战距离内生效",
    details = "启用后，精灵之火（野性）与精灵之火（野性）（清晰预兆）仅在目标位于近战距离内时执行。不影响平衡系精灵之火。作为被动规则，启用时影响当前流程。",
    sort = 143,
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

function card.Apply(context)
    context.parameters.faerieFireFeralMeleeOnly = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
