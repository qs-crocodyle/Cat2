-- 生命分流精确版：以绝对蓝量触发，并提供可配置的最低生命值保护。
local card = {
    id = "warlock_life_tap_exact",
    name = "生命分流（精确）",
    description = "蓝量<|cff6bc7e0{manaThreshold}|r且血量不低于|cff6bc7e0{minimumHealth}|r时，施放生命分流",
    details = "当前绝对蓝量低于设定值，且当前血量不低于设定下限时施放生命分流。默认蓝量阈值3000、最低血量400；血量低于设定下限时不会施放。成功执行时会阻断本轮后续卡片。",
    sort = 150.05,
    category = "class",
    exclusiveGroup = "warlock_life_tap",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_BurningSpirit",
    },
    optionSchema = {
        {
            key = "manaThreshold",
            type = "number",
            label = "触发蓝量",
            shortLabel = "蓝",
            unit = "",
            default = 3000,
            minimum = 1,
            maximum = 100000,
        },
        {
            key = "minimumHealth",
            type = "number",
            label = "最低血量",
            shortLabel = "血",
            unit = "",
            default = 400,
            minimum = 1,
            maximum = 100000,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local manaThreshold = context:GetStepOption(step, "manaThreshold") or 3000
    local minimumHealth = context:GetStepOption(step, "minimumHealth") or 400

    if player.mana < manaThreshold and player.health >= minimumHealth then
        Cat2.Cast("生命分流")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
