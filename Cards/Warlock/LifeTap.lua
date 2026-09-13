-- 生命分流 技能卡片。
local card = {
    id = "warlock_life_tap",
    name = "生命分流",
    description = "蓝量<|cff6bc7e0{triggerPercent}%|r时，施放生命分流",
    details = "蓝量低于卡片设定值时，施放生命分流。会检查相关生命值。成功执行时会阻断本轮后续卡片。",
    sort = 150,
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
            key = "triggerPercent",
            type = "number",
            label = "触发蓝量",
            shortLabel = "蓝",
            unit = "%",
            default = 50,
            minimum = 1,
            maximum = 99,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 50

    if player.percentMana < triggerPercent and player.health > 400 then
        Cat2.Cast("生命分流")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
