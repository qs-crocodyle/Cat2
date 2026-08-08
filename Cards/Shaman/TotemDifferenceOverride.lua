-- 图腾差异覆盖被动卡片；具体参数效果留给后续规则实现。
local card = {
    id = "shaman_totem_difference_override",
    name = "差异覆盖",
    description = "强制覆盖已有(已经插好的)同系的不同图腾",
    details = "强制覆盖已有(已经插好的)同系的不同图腾。作为被动规则，启用时影响当前流程。",
    sort = 220,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_CurseOfMannoroth",
    },
}

function card.RefreshRuntimeData()
end

-- 暂不写入具体参数，后续可在这里实现差异覆盖规则。
function card.Apply(context)
    context.parameters.TotemForceOverride = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
