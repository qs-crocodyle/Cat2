-- 吸取灵魂 技能卡片。
local card = {
    id = "warlock_drain_soul",
    name = "吸取灵魂",
    description = "施放吸取灵魂",
    details = "施放吸取灵魂。需要存在有效目标；目标暗影免疫时不会施放。成功执行时会阻断本轮后续卡片。",
    sort = 120,
    exclusiveGroup = "warlock_drain_spell",
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_Haunting",
    },
}

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("吸取灵魂", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 30
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

    Cat2.Cast("吸取灵魂")
    return true

end

Cat2.RegisterCard(card)
