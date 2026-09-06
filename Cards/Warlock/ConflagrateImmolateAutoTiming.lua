-- 燃烧（献祭自动计时）技能卡片。
local card = {
    id = "warlock_conflagrate_immolate_auto_timing",
    name = "燃烧（献祭自动计时）",
    description = "有足够献祭时间时，技能冷却后施放燃烧",
    details = "有足够献祭时间时，技能冷却后施放燃烧。需要存在有效目标；目标火焰免疫时不会施放。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 66,
    category = "class",
    classes = {
        WARLOCK = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Fireball",
        "Interface\\Icons\\Spell_Fire_Immolation",
    },
    cooldown = { type = "spell", name = "燃烧" },
}

local allowUse = 0
local distance = 30

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(3,16)
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("燃烧", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 30
    end
end

function card.Execute(context)
    if allowUse==0 then
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
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    local castTime = tonumber(Cat2.Match(Cat2.GetSpellTooltip("献祭"), "([0-9]+[.]?[0-9]*)秒施法时间")) - 0.1

    if Cat2.SpellReadyOffset("燃烧") and Cat2.GetImmolateDot("target", castTime+3.0) then
        Cat2.Cast("燃烧")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
