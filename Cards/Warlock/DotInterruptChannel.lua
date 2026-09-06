-- 允许痛苦系持续伤害法术主动打断当前引导。
local card = {
    id = "warlock_dot_interrupt_channel",
    name = "允许DOT打断吸取",
    description = "需要补DOT时，允许中断三种吸取类引导法术",
    details = "启用后，痛苦系持续伤害法术需要补充时，仅允许中断吸取生命、吸取法力或吸取灵魂，再施放对应DOT。其他引导法术不会被中断。作为被动规则，启用时影响当前流程。",
    sort = 121,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_SearingLightPriest",
    },
}

function card.RefreshRuntimeData()
end

-- 被动卡先于普通卡片应用，因此不受自身在流程中的排列位置影响。
function card.Apply(context)
    context.parameters.warlockDotInterruptChannel = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
