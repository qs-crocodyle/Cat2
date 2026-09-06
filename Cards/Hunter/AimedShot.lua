-- 瞄准射击 技能卡片。
local card = {
    id = "hunter_aimed_shot",
    name = "瞄准射击",
    description = "目标距离不低于8码时，降低占用自动射击",
    details = "目标距离不低于8码时，降低占用自动射击，荷枪实弹影响瞄准射击的时机。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 45,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\INV_Spear_07",
    },
    cooldown = {
        type = "spell",
        name = "瞄准射击",
    },
}

local allowUse = 0
local minimumDistance = 8
local maximumDistance = 35

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(2,6)
    local minimum, maximum = Cat2.Match(Cat2.GetSpellTooltip("瞄准射击", "等级 1"), "(%d+)%s*%-%s*(%d+)码距离")
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

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    -- 技能未准备好
    if not Cat2.SpellReady("瞄准射击") then
        return false
    end

    local range_speed = UnitRangedDamage("player") / 2

    if player.buff["荷枪实弹"] then
        range_speed = range_speed - 1.0
    end

    if player.buff["急速射击"] then
        range_speed = range_speed - 0.5
    end

    if Cat2.GetHunterShotLeft()>range_speed then
        Cat2.Cast("瞄准射击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
