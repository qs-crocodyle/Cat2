-- 稳固射击技能卡片。
local card = {
    id = "hunter_steady_shot",
    name = "稳固射击",
    description = "自动射击剩余>|cff6bc7e0{shotThreshold}秒|r时施放，急速射击时阈值-0.5秒",
    details = "目标距离不低于8码，且自动射击剩余时间高于卡片设定阈值时施放稳固射击；存在急速射击效果时，实际阈值降低0.5秒。默认射击阈值为1.5秒。需要存在有效目标。会检查目标距离。成功执行时会阻断本轮后续卡片。",
    sort = 55,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Hunter_SteadyShot",
    },
    optionSchema = {
        {
            key = "shotThreshold",
            type = "number",
            label = "射击阈值",
            shortLabel = "阈值",
            unit = "秒",
            default = 1.5,
            minimum = 0.5,
            maximum = 5,
            integer = false,
        },
    },
}

local minimumDistance = 8
local maximumDistance = 35

function card.RefreshRuntimeData()
    local minimum, maximum = Cat2.Match(Cat2.GetSpellTooltip("稳固射击", "等级 1"), "(%d+)%s*%-%s*(%d+)码距离")
    minimumDistance = tonumber(minimum) or 8
    maximumDistance = tonumber(maximum) or 35
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local shotThreshold = context:GetStepOption(step, "shotThreshold") or 1.5

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

    if player.buff["急速射击"] then
        shotThreshold = shotThreshold - 0.5
    end

    if Cat2.GetHunterShotLeft()>shotThreshold then
        Cat2.Cast("稳固射击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
