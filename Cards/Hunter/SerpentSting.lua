-- 毒蛇钉刺 技能卡片。
local card = {
    id = "hunter_serpent_sting",
    name = "毒蛇钉刺",
    description = "目标距离不低于8码且可以中毒时，施放毒蛇钉刺",
    details = "目标距离不低于8码且可以中毒时，施放毒蛇钉刺。不会对机械或元素生物施放，并会检查自然免疫、目标已有毒蛇钉刺和目标距离。成功执行时会阻断本轮后续卡片。",
    sort = 60,
    category = "class",
    exclusiveGroup = "hunter_sting",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Hunter_Quickshot",
    },
}

local minimumDistance = 8
local maximumDistance = 35

function card.RefreshRuntimeData()
    local minimum, maximum = Cat2.Match(Cat2.GetSpellTooltip("毒蛇钉刺", "等级 1"), "(%d+)%s*%-%s*(%d+)码距离")
    minimumDistance = tonumber(minimum) or 8
    maximumDistance = tonumber(maximum) or 35
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if context.parameters.hunterStingOnlyBoss and not Cat2.IsBossTarget() then
        return false
    end

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end

    -- 机械和元素生物无法中毒
    if player.targetCreatureType == "机械" or player.targetCreatureType == "元素生物" then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and (targetDistance < minimumDistance or targetDistance > maximumDistance) then
            return false
        end
    end

    -- 自然免疫
    if Cat2.IsNatureImmune() then
        return false
    end

    if not Cat2.GetSerpentStingDot() then
        Cat2.Cast("毒蛇钉刺")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
