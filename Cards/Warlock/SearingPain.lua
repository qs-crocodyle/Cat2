-- 灼热之痛 技能卡片。
local card = {
    id = "warlock_searing_pain",
    name = "灼热之痛",
    description = "施放灼热之痛，适合做填充技能",
    details = "施放灼热之痛，适合做填充技能。需要存在有效目标；目标火焰免疫时不会施放。成功执行时会阻断本轮后续卡片。",
    sort = 30,
    category = "class",
    classes = {
        WARLOCK = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_SoulBurn",
    },
}

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("灼热之痛", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 30
    end
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
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    Cat2.Cast("灼热之痛")
    return true
end

Cat2.RegisterCard(card)
