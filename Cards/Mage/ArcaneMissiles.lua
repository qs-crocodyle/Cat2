-- 奥术飞弹 技能卡片。
local card = {
    id = "mage_arcane_missiles",
    name = "奥术飞弹",
    description = "施放奥术飞弹，适合做填充技能",
    details = "施放奥术飞弹，适合做填充技能。需要存在有效目标；目标奥术免疫时不会施放。成功执行时会阻断本轮后续卡片。",
    sort = 10,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_StarFall",
    },
}

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("奥术飞弹", "等级 1"), "(%d+)码距离"))
    if not distance then distance = 30 end
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 目标奥术免疫时，不再尝试施放奥术伤害技能。
    if Cat2.IsArcaneImmune() then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    Cat2.Cast("奥术飞弹")
    return true
end

Cat2.RegisterCard(card)
