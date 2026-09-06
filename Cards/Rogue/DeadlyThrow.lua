-- 致命投掷技能卡片。
local card = {
    id = "rogue_deadly_throw",
    name = "致命投掷",
    description = "冷却时，施放致命投掷",
    details = "冷却时，施放致命投掷。远程栏必须装备投掷武器。需要存在有效目标。会检查目标距离。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 11,
    category = "class",
    classes = {
        ROGUE = 1,
    },
    icons = {
        "Interface\\Icons\\INV_ThrowingKnife_03",
    },
    cooldown = {
        type = "spell",
        name = "致命投掷",
    },
}

local range = 30

function card.RefreshRuntimeData()
    local fallbackRange = 30 + (Cat2.IsTalentLearned(1,8)*3)
    range = tonumber(Cat2.Match(Cat2.GetSpellTooltip("致命投掷", "等级 1"), "(%d+)码距离"))
    if not range then range = fallbackRange end
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    -- 致命投掷必须由远程栏中的投掷武器支持。
    if not Cat2.IsRangedThrownWeapon() then
        return false
    end

    if not player.targetExists then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and (targetDistance <= 8 or targetDistance > range) then
            return false
        end
    end

    if player.power >= 40 and Cat2.SpellReady("致命投掷") then
        Cat2.Cast("致命投掷")
        return true
    end


    return false
end

Cat2.RegisterCard(card)
