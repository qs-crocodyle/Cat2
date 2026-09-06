-- 愤怒切换神像被动卡：为所有愤怒施法分支提供施法前神像切换参数。
local card = {
    id = "druid_wrath_idol_switch",
    name = "愤怒切换神像",
    description = "施放愤怒前切换为|cff6bc7e0{idolName}|r",
    details = "愤怒及其分支满足施放条件时，在实际施放前尝试将圣物栏切换为所选神像。已经装备或背包中没有所选神像时不会重复操作。作为被动规则，启用时影响当前流程。",
    sort = 999,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        DRUID = 1,
    },
    icons = {
        "Interface\\Icons\\INV_QirajIdol_Night",
        "Interface\\Icons\\Spell_Nature_AbolishMagic",
    },
    optionSchema = {
        {
            key = "idolName",
            type = "string",
            control = "select",
            label = "神像名称",
            shortLabel = "神像",
            default = "酸蚀神像",
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
    context.parameters.druidWrathIdol = context:GetStepOption(step, "idolName") or ""
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
