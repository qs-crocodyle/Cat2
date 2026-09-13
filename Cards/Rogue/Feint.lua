-- 佯攻技能卡片；冷却完成且能量足够时施放。
local card = {
    id = "rogue_feint",
    name = "佯攻",
    description = "仇恨>|cff6bc7e0{threatPercent}%|r时施放佯攻",
    details = "目标存在、存活且可攻击，佯攻冷却完成、能量足够且自身仇恨高于卡片设定值时施放。默认仇恨门槛为80%；无法获取有效仇恨数据时跳过，继续后续卡片。",
    sort = 92,
    category = "class",
    canStopSequence = true,
    classes = {
        ROGUE = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_Feint",
    },
    cooldown = {
        type = "spell",
        name = "佯攻",
    },
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

    if not UnitExists("target") or UnitIsDeadOrGhost("target")
        or not UnitCanAttack("player", "target") then
        return false
    end

    -- 无有效仇恨数据时放行后续卡片，不再尝试后备施法。
    local threat = Cat2.GetHatredFromTWT()
    if type(threat) ~= "number" or not (threat > threatPercent) then
        return false
    end

    if player.power >= 20 and Cat2.SpellReady("佯攻") then
        Cat2.Cast("佯攻")
        return true
    end


    return false
end

Cat2.RegisterCard(card)
