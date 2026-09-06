-- 灼烧 技能卡片。
local card = {
    id = "mage_scorch",
    name = "灼烧",
    description = "施放灼烧，适合作为填充技能",
    details = "施放灼烧，适合作为填充技能。需要存在有效目标；目标火焰免疫时不会施放。",
    sort = 40,
    category = "class",
    classes = {
        MAGE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_SoulBurn",
    },
}

local range = 30

function card.RefreshRuntimeData()
    local fallbackRange = 30 + (Cat2.IsTalentLearned(2,3)*3)
    range = tonumber(Cat2.Match(Cat2.GetSpellTooltip("灼烧", "等级 1"), "(%d+)码距离"))
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

    Cat2.Cast("灼烧")

    return false

end

Cat2.RegisterCard(card)
