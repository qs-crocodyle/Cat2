-- 火焰冲击（移动时）技能卡片。
local card = {
    id = "mage_fire_blast_move",
    name = "火焰冲击（移动时）",
    description = "移动时，冷却好后施放火焰冲击",
    details = "移动时，冷却好后施放火焰冲击。需要存在有效目标；目标火焰免疫时不会施放。会检查目标距离与移动状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 21,
    category = "class",
    classes = {
        MAGE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Fireball",
    },
    cooldown = {
        type = "spell",
        name = "火焰冲击",
    },
}

local range = 20

function card.RefreshRuntimeData()
    local fallbackRange = 20 + (Cat2.IsTalentLearned(2,3)*3)
    range = tonumber(Cat2.Match(Cat2.GetSpellTooltip("火焰冲击", "等级 1"), "(%d+)码距离"))
    if not range then range = fallbackRange end
end

function card.Execute(context)
    if not Cat2.PlayerIsMoving() then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 目标火焰免疫时，不再尝试施放火焰伤害技能。
    if Cat2.IsFireImmune() then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > range then
            return false
        end
    end

    if Cat2.SpellReady("火焰冲击") then
        Cat2.Cast("火焰冲击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
