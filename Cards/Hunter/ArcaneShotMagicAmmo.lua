-- 奥术射击（魔力弹药）技能卡片。
local card = {
    id = "hunter_arcane_shot_magic_ammo",
    name = "奥术射击（魔力弹药）",
    description = "目标距离不低于8码且触发魔力弹药时，施放奥术射击",
    details = "目标距离不低于8码且触发魔力弹药时，施放奥术射击。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 55.7,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_ImpalingBolt",
    },
}

local minimumDistance = 8
local maximumDistance = 35

function card.RefreshRuntimeData()
    local minimum, maximum = Cat2.Match(Cat2.GetSpellTooltip("奥术射击", "等级 1"), "(%d+)%s*%-%s*(%d+)码距离")
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

    if player.buff["魔力弹药"] and Cat2.SpellReady("奥术射击") then
        Cat2.Cast("奥术射击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
