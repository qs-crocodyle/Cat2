-- 灵魂之火 技能卡片。
local card = {
    id = "warlock_soul_fire",
    name = "灵魂之火",
    description = "目标血量不低于|cff6bc7e0{minimumTargetHealth}|r且碎片>|cff6bc7e0{minimumShards}|r个时，施放灵魂之火",
    details = "目标血量不低于卡片设定值且技能冷却完成时，施放灵魂之火；目标血量低于设定值时不会施放。默认最低目标血量为3000。需要存在有效目标；目标火焰免疫时不会施放。碎片下限默认1，可设为1至1000的整数。仅在背包灵魂碎片数量严格大于下限且技能可用时尝试施放；设为X即保留X片，例如希望保留5片应设为5。尝试施放后会阻断本轮后续卡片。",
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
        {
            key = "minimumShards",
            type = "number",
            label = "碎片下限",
            shortLabel = "片",
            unit = "个",
            default = 1,
            minimum = 1,
            maximum = 1000,
            integer = true,
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
    local minimumShards = context:GetStepOption(step, "minimumShards") or 1
    if Cat2.GetItemByNameCount("灵魂碎片") <= minimumShards then
        return false
    end

    if Cat2.SpellReadyOffset("灵魂之火") then
        Cat2.Cast("灵魂之火")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
