-- 灵魂之火 技能卡片。
local card = {
    id = "warlock_soul_fire",
    name = "灵魂之火",
    description = "目标血量不低于|cff6bc7e0{minimumTargetHealth}|r时，施放灵魂之火",
    details = "目标血量不低于卡片设定值且技能冷却完成时，施放灵魂之火；目标血量低于设定值时不会施放。默认最低目标血量为3000。需要存在有效目标；目标火焰免疫时不会施放。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 40,
    category = "class",
    classes = {
        WARLOCK = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Fireball02",
    },
    optionSchema = {
        {
            key = "minimumTargetHealth",
            type = "number",
            label = "目标最低血量",
            shortLabel = "血量",
            default = 3000,
            minimum = 0,
            maximum = 1000000,
        },
    },
}

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("灵魂之火", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 30
    end
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local minimumTargetHealth = context:GetStepOption(step, "minimumTargetHealth") or 3000

    if not player.targetExists then
        return false
    end

    if player.targetHealth < minimumTargetHealth then
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

    -- 灵魂碎片保护
    if Cat2.GetItemByNameID("灵魂碎片") <= 0 then
        return false
    end

    if Cat2.SpellReadyOffset("灵魂之火") then
        Cat2.Cast("灵魂之火")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
