-- 允许夜幕触发的瞬发暗影箭主动打断当前吸取引导。
local card = {
    id = "warlock_nightfall_interrupt_channel",
    name = "允许夜幕打断吸取",
    description = "夜幕触发时，允许中断三种吸取类引导法术",
    details = "启用后，夜幕触发的瞬发暗影箭仅允许中断吸取生命、吸取法力或吸取灵魂。其他引导法术不会被中断。作为被动规则，启用时影响当前流程。",
    sort = 122,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_SearingLightPriest",
        "Interface\\Icons\\Spell_Shadow_Twilight",
    },
}

function card.RefreshRuntimeData()
end

function card.Apply(context)
    context.parameters.warlockNightfallInterruptChannel = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
