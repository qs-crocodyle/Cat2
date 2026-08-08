-- 燃烧 技能卡片。
local card = {
    id = "warlock_conflagrate",
    name = "燃烧",
    description = "技能冷却后，施放燃烧",
    details = "技能冷却后，施放燃烧。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 60,
    category = "class",
    classes = {
        WARLOCK = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Fireball",
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

    if Cat2.SpellReadyOffset("燃烧") then
        CastSpellByName("燃烧")
        return true
    end

    return false
end

Cat2.RegisterCard(card)