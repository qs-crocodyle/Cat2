-- 闪电打击切换图腾占位卡；具体逻辑后续补充。
local card = {
    id = "shaman_lightning_strike_totem_switch",
    name = "闪电打击切换图腾",
    description = "闪电打击时切换为|cff6bc7e0{totemName}|r",
    details = "闪电打击冷却即将结束且当前处于公共冷却前半段时，尝试将圣物栏切换为所选图腾。换装本身不会阻断流程；同一轮只处理第一张满足条件的图腾联动卡。参数可从菜单选择，也可手动输入其他名称；已经装备或背包中没有所选图腾时不会重复操作。作为被动规则，启用时影响当前流程。",
    sort = 81,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        SHAMAN = 2,
    },
    icons = {
        "Interface\\Icons\\INV_QirajIdol_Life",
        "Interface\\Icons\\Spell_Nature_ThunderClap",
    },
    optionSchema = {
        {
            key = "totemName",
            type = "string",
            control = "select",
            allowCustom = true,
            label = "图腾名称",
            shortLabel = "图腾",
            default = "裂雷图腾",
            choices = {
                { value = "裂雷图腾", label = "|cFF9D38C8裂雷图腾|r" },
                { value = "破碎大地图腾", label = "|cFF9D38C8破碎大地图腾|r" },
                { value = "裂石图腾", label = "|cFF9D38C8裂石图腾|r" },
                { value = "召雷图腾", label = "|cFF9D38C8召雷图腾|r" },
                { value = "余震图腾", label = "|cFF9D38C8余震图腾|r" },
                { value = "怒气图腾", label = "|cFF0070DD怒气图腾|r" },
                { value = "星火图腾", label = "|cFF0070DD星火图腾|r" },
                { value = "腐根图腾", label = "|cFF0070DD腐根图腾|r" },
                { value = "腐潮图腾", label = "|cFF0070DD腐潮图腾|r" },
            },
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Apply(context, step)
    context.parameters.shamanLightningStrikeTotem = context:GetStepOption(step, "totemName") or ""
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
