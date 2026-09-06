-- 炎爆术 技能卡片。
local card = {
    id = "mage_pyroblast",
    name = "炎爆术",
    description = "施放炎爆术",
    details = "施放炎爆术。需要存在有效目标；目标火焰免疫时不会施放。成功执行时会阻断本轮后续卡片。",
    sort = 50,
    category = "class",
    classes = {
        MAGE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Fireball02",
    },
}

local allowUse = 0
local range = 35

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(2,8)
    local fallbackRange = 35 + (Cat2.IsTalentLearned(2,3)*3)
    range = tonumber(Cat2.Match(Cat2.GetSpellTooltip("炎爆术", "等级 1"), "(%d+)码距离"))
    if not range then range = fallbackRange end
end

function card.Execute(context)

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

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    Cat2.Cast("炎爆术")

    return true

end

Cat2.RegisterCard(card)
