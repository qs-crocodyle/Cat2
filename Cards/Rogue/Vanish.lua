-- 消失技能卡片。
local card = {
    id = "rogue_vanish",
    name = "消失",
    description = "被目标盯着，且生命低于|cff6bc7e0{triggerPercent}%|r时施放消失",
    details = "被目标盯着，且生命低于卡片设定值时施放消失。需要存在有效目标。仅在技能可用时尝试执行。",
    sort = 121,
    category = "class",
    classes = {
        ROGUE = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Vanish",
    },
    cooldown = {
        type = "spell",
        name = "消失",
    },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发生命",
            shortLabel = "血",
            unit = "%",
            default = 30,
            minimum = 1,
            maximum = 99,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 30

    if not player.targetExists then
        return false
    end

    -- 目标的目标缺失
    if not UnitExists("targettarget") then
        return false
    end

    local targetTargetName = UnitName("targettarget")
    if targetTargetName and targetTargetName==Cat2.PlayerInformation.basic.name then

        if player.percentHealth <= triggerPercent and Cat2.SpellReady("消失") then
            Cat2.Cast("消失")
        end

    end

    return false
end

Cat2.RegisterCard(card)
