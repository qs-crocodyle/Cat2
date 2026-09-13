-- 畏缩技能卡片；猎豹形态下冷却完成且能量足够时施放。
local card = {
    id = "druid_cower",
    name = "畏缩",
    description = "猎豹形态下，仇恨>|cff6bc7e0{threatPercent}%|r时施放畏缩",
    details = "猎豹形态下，目标存在、存活且可攻击，畏缩冷却完成、能量足够且自身仇恨高于卡片设定值时施放。默认仇恨门槛为80%；无法获取有效仇恨数据时跳过，继续后续卡片。",
    sort = 423.3,
    category = "class",
    canStopSequence = true,
    classes = {
        DRUID = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Druid_Cower",
    },
    cooldown = { type = "spell", name = "畏缩" },
    optionSchema = {
        {
            key = "threatPercent",
            type = "number",
            label = "触发仇恨",
            shortLabel = "仇恨",
            unit = "%",
            default = 80,
            minimum = 1,
            maximum = 100,
        },
    },
}

function card.RefreshRuntimeData()
end



function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local threatPercent = context:GetStepOption(step, "threatPercent") or 80

    if not player.buff["猎豹形态"] then
        return false
    end

    if not UnitExists("target") or UnitIsDeadOrGhost("target")
        or not UnitCanAttack("player", "target") then
        return false
    end

    -- 无有效仇恨数据时放行后续卡片，不再尝试后备施法。
    local threat = Cat2.GetHatredFromTWT()
    if type(threat) ~= "number" or not (threat > threatPercent) then
        return false
    end

    if player.power >= 20 and Cat2.SpellReady("畏缩") then
        Cat2.Cast("畏缩")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
