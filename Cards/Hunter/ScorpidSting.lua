-- 毒蝎钉刺 技能卡片。
local card = {
    id = "hunter_scorpid_sting",
    name = "毒蝎钉刺",
    description = "目标距离不低于8码时，施放并保持毒蝎钉刺",
    details = "目标距离不低于8码时，施放并保持毒蝎钉刺。需要存在有效目标。会检查目标距离。成功执行时会阻断本轮后续卡片。",
    sort = 80,
    category = "class",
    exclusiveGroup = "hunter_sting",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Hunter_CriticalShot",
    },
}

local minimumDistance = 8
local maximumDistance = 35

function card.RefreshRuntimeData()
    local minimum, maximum = Cat2.Match(Cat2.GetSpellTooltip("毒蝎钉刺", "等级 1"), "(%d+)%s*%-%s*(%d+)码距离")
    minimumDistance = tonumber(minimum) or 8
    maximumDistance = tonumber(maximum) or 35
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and (targetDistance < minimumDistance or targetDistance > maximumDistance) then
            return false
        end
    end

    if not Cat2.GetScorpidStingDot() then
        Cat2.Cast("毒蝎钉刺")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
