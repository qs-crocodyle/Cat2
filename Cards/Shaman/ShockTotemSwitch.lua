-- 震击切换图腾占位卡；具体逻辑后续补充。
local card = {
    id = "shaman_shock_totem_switch",
    name = "震击切换图腾",
    description = "震击时切换为|cff6bc7e0{totemName}|r",
    details = "大地震击、冰霜震击、烈焰震击及烈焰震击（持续DOT）冷却即将结束且当前处于公共冷却前半段时，尝试将圣物栏切换为所选图腾，不影响这些技能的其他分支。大地震击同时存在专属切换被动时优先使用专属参数。换装本身不会阻断流程；同一轮只处理第一张满足条件的图腾联动卡。参数可从菜单选择，也可手动输入其他名称；已经装备或背包中没有所选图腾时不会重复操作。作为被动规则，启用时影响当前流程。",
    sort = 84,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        SHAMAN = 2,
    },
    icons = {
        "Interface\\Icons\\INV_QirajIdol_Life",
        "Interface\\Icons\\Spell_Frost_FrostShock",
    },
    optionSchema = {
        {
            key = "totemName",
            type = "string",
            control = "select",
            allowCustom = true,
            label = "图腾名称",
            shortLabel = "图腾",
            default = "裂石图腾",
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
    context.parameters.shamanShockTotem = context:GetStepOption(step, "totemName") or ""
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
