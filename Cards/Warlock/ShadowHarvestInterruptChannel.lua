-- 允许暗影收割主动打断当前吸取引导。
local card = {
    id = "warlock_shadow_harvest_interrupt_channel",
    name = "允许暗影收割打断吸取",
    description = "暗影收割可用时，允许中断三种吸取类引导法术",
    details = "启用后，暗影收割仅允许中断吸取生命、吸取法力或吸取灵魂。其他引导法术不会被中断。作为被动规则，启用时影响普通暗影收割与暗影易伤版本。",
    sort = 123,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_SearingLightPriest",
        "Interface\\Icons\\Spell_Shadow_SoulLeech",
    },
}

function card.RefreshRuntimeData()
end

function card.Apply(context)
    context.parameters.warlockShadowHarvestInterruptChannel = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
