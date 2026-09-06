-- 吸取生命 技能卡片。
local card = {
    id = "warlock_drain_life",
    name = "吸取生命",
    description = "施放吸取生命",
    details = "施放吸取生命。需要存在有效目标；目标暗影免疫时不会施放。成功执行时会阻断本轮后续卡片。",
    sort = 100,
    exclusiveGroup = "warlock_drain_spell",
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_LifeDrain02",
    },
}

local distance = 20

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("吸取生命", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 20
    end
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 目标暗影免疫时，不再尝试施放暗影伤害技能。
    if Cat2.IsShadowImmune() then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    -- 目标吸血条件
    if not Cat2.IsDrain() then
        return false
    end

    Cat2.Cast("吸取生命")
    return true

end

Cat2.RegisterCard(card)
