-- 燃烧（献祭）技能卡片。
local card = {
    id = "warlock_conflagrate_immolate",
    name = "燃烧（献祭）",
    description = "有足够献祭时间时，技能冷却后施放燃烧",
    details = "有足够献祭时间时，技能冷却后施放燃烧。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 65,
    category = "class",
    classes = {
        WARLOCK = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Fireball",
        "Interface\\Icons\\Spell_Fire_Immolation",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(3,16)
end

function card.Execute(context)
    if allowUse==0 then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if Cat2.SpellReadyOffset("燃烧") and Cat2.GetImmolateDot("target", 4) then
        CastSpellByName("燃烧")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
