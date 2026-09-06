-- 自动水之护盾回蓝卡片。
-- 与普通护盾卡不互斥：低蓝时自动维持水之护盾，高蓝后交还给流程中的其他护盾卡。
local card = {
    id = "shaman_auto_water_shield_mana",
    name = "自动 水之护盾回蓝",
    description = "当蓝量<|cff6bc7e0{triggerManaPercent}%|r启动回蓝，蓝量>|cff6bc7e0{stopManaPercent}%|r停止",
    details = "蓝量低于触发值时自动施放并维持水之护盾；蓝量高于停止值时退出回蓝状态。未单独设置时，触发蓝量为30%，停止触发为50%。本卡不属于护盾小组，可与普通护盾卡同时装填。",
    sort = 49,
    category = "class",
    classes = {
        SHAMAN = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Shaman_WaterShield",
    },
    optionSchema = {
        {
            key = "triggerManaPercent",
            type = "number",
            label = "触发蓝量",
            unit = "%",
            default = 30,
            minimum = 1,
            maximum = 99,
        },
        {
            key = "stopManaPercent",
            type = "number",
            label = "停止触发",
            unit = "%",
            default = 50,
            minimum = 1,
            maximum = 99,
        },
    },
}

-- 回蓝状态仅用于维持触发值至停止值之间的滞后区间。
local restoringMana = false

function card.RefreshRuntimeData()
end

function card.GetCustomValue(context)
    return restoringMana
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local triggerManaPercent = context:GetStepOption(step, "triggerManaPercent") or 30
    local stopManaPercent = context:GetStepOption(step, "stopManaPercent") or 50

    if not restoringMana and player.percentMana < triggerManaPercent then
        restoringMana = true
    end

    if player.percentMana > stopManaPercent then
        restoringMana = false
    end

    if restoringMana and not player.buff["水之护盾"] then
        Cat2.Cast("水之护盾")
    end

    return false
end

Cat2.RegisterCard(card)
