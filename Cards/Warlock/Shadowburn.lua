-- 暗影灼烧 技能卡片。
local card = {
    id = "warlock_shadowburn",
    name = "暗影灼烧",
    description = "碎片>|cff6bc7e0{minimumShards}|r个且技能冷却后，施放暗影灼烧",
    details = "技能冷却后，施放暗影灼烧。需要存在有效目标；目标暗影免疫时不会施放。碎片下限默认1，可设为1至1000的整数。仅在背包灵魂碎片数量严格大于下限且技能可用时尝试施放；设为X即保留X片，例如希望保留5片应设为5。尝试施放后会阻断本轮后续卡片。",
    sort = 50,
    category = "class",
    classes = {
        WARLOCK = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_ScourgeBuild",
    },
    cooldown = { type = "spell", name = "暗影灼烧" },
    optionSchema = {
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

local allowUse = 0
local distance = 20

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(3,7)
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("暗影灼烧", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 20
    end
end

function card.Execute(context, step)

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

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

    -- 灵魂碎片保护
    local minimumShards = context:GetStepOption(step, "minimumShards") or 1
    if Cat2.GetItemByNameCount("灵魂碎片") <= minimumShards then
        return false
    end

    if Cat2.SpellReadyOffset("暗影灼烧") then
        Cat2.Cast("暗影灼烧")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
