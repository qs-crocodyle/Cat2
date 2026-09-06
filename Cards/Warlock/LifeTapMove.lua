-- 生命分流（移动时）技能卡片。
local card = {
    id = "warlock_life_tap_move",
    name = "生命分流（移动时）",
    description = "移动且蓝量<|cff6bc7e0{triggerPercent}%|r时，施放生命分流",
    details = "玩家移动中且蓝量低于卡片设定值时，施放生命分流。会检查相关生命值；静止时不执行。成功执行时会阻断本轮后续卡片。",
    sort = 150.1,
    category = "class",
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

    if not Cat2.PlayerIsMoving() then
        return false
    end

    local player = Cat2.PlayerInformation.temporary
    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 50

    if player.percentMana < triggerPercent and player.health > 400 then
        Cat2.Cast("生命分流")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
