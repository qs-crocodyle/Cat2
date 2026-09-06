-- 星火术切换神像被动卡：为所有星火术施法分支提供施法前神像切换参数。
local card = {
    id = "druid_starfire_idol_switch",
    name = "星火术切换神像",
    description = "施放星火术前切换为|cff6bc7e0{idolName}|r",
    details = "星火术及其分支满足施放条件时，在实际施放前尝试将圣物栏切换为所选神像。已经装备或背包中没有所选神像时不会重复操作。作为被动规则，启用时影响当前流程。",
    sort = 1000,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        DRUID = 1,
    },
    icons = {
        "Interface\\Icons\\INV_QirajIdol_Night",
        "Interface\\Icons\\Spell_Arcane_StarFire",
    },
    optionSchema = {
        {
            key = "idolName",
            type = "string",
            control = "select",
            label = "神像名称",
            shortLabel = "神像",
            default = "潮汐神像",
            choices = {
                { value = "潮汐神像", label = "|cFF9D38C8潮汐神像|r" },
                { value = "平衡神像", label = "|cFF9D38C8平衡神像|r" },
                { value = "月牙神像", label = "|cFF9D38C8月牙神像|r" },
                { value = "酸蚀神像", label = "|cFF9D38C8酸蚀神像|r" },
            },
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Apply(context, step)
    context.parameters.druidStarfireIdol = context:GetStepOption(step, "idolName") or ""
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
