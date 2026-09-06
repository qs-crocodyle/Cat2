-- 圣骑士防护系：正义壁垒。
local card = {
    id = "paladin_righteous_bulwark",
    name = "正义壁垒",
    description = "生命<|cff6bc7e0{triggerPercent}%|r时施放正义壁垒",
    details = "生命低于卡片设定值时施放正义壁垒。需要存在有效目标。会检查战斗状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 110,
    category = "class",
    classes = {
        PALADIN = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_VictoryRush",
    },
    cooldown = {
        type = "spell",
        name = "正义壁垒",
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

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end

    -- 必须有盾牌
    if not Cat2.IsOffHandShield() then
        return false
    end


    if not Cat2.SpellReady("正义壁垒") then
        return false
    end

    if player.percentHealth < triggerPercent then
        Cat2.Cast("正义壁垒")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
