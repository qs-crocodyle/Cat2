-- 仅在荷枪实弹生效时使用瞄准射击的技能卡片。
local card = {
    id = "hunter_aimed_shot_lock_and_load",
    name = "瞄准射击（荷枪实弹）",
    description = "荷枪实弹生效且目标距离不低于8码时",
    details = "仅在荷枪实弹生效时使用瞄准射击。目标距离不低于8码时，降低占用自动射击。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 46,
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

    if not player.targetExists or not player.buff["荷枪实弹"] then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and (targetDistance < minimumDistance or targetDistance > maximumDistance) then
            return false
        end
    end

    if allowUse==0 then
        return false
    end

    if not Cat2.SpellReady("瞄准射击") then
        return false
    end

    Cat2.Cast("瞄准射击")
    return true

end

Cat2.RegisterCard(card)
