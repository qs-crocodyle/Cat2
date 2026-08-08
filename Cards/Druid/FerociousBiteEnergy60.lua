-- 调整凶猛撕咬能量上限为 60 的被动卡片。
local card = {
    id = "druid_ferocious_bite_energy_60",
    name = "凶猛撕咬 调整能量<60",
    description = "将凶猛撕咬的能量上限调整为60",
    details = "将凶猛撕咬的能量上限调整为60。作为被动规则，启用时影响当前流程。",
    sort = 442,
    behavior = "passive",
    unique = true,
    exclusiveGroup = "druid_ferocious_bite_energy_limit",
    category = "class",
    classes = {
        DRUID = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Druid_FerociousBite",
    },
}

function card.RefreshRuntimeData()
end

function card.Apply(context)
    context.parameters.ferociousBiteEnergyLimit = 60
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
