-- 自动蝰蛇守护技能卡片。
-- 与普通守护卡不互斥：低蓝时自动维持蝰蛇守护，高蓝后交还给流程中的其他守护卡。
local card = {
    id = "hunter_auto_aspect_of_the_viper",
    name = "自动 蝰蛇守护回蓝",
    description = "当蓝量<|cff6bc7e0{triggerManaPercent}%|r启动回蓝，蓝量>|cff6bc7e0{stopManaPercent}%|r停止",
    details = "蓝量低于触发值时自动切换并维持蝰蛇守护；蓝量高于停止值时退出回蓝状态。未单独设置时，触发蓝量为30%，停止触发为50%。本卡不属于守护小组，可与普通守护卡同时装填。",
    sort = 9,
    category = "class",
    classes = {
        HUNTER = 1,
    },
    icons = {
        "Interface\\Icons\\ability_hunter_aspectoftheviper",
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

-- 回蓝状态仅用于维持 触发值 至 停止值 之间的滞后区间。
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

    if not restoringMana and player.percentMana<triggerManaPercent then
        restoringMana = true
    end
    
    if player.percentMana > stopManaPercent then
        restoringMana = false
    end

    if restoringMana and not player.buff["蝰蛇守护"] then
        Cat2.Cast("蝰蛇守护")
    end

    return false
end

Cat2.RegisterCard(card)
