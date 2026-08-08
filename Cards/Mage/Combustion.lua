-- 燃烧 技能卡片。
local card = {
    id = "mage_combustion",
    name = "燃烧",
    description = "技能冷却后，施放燃烧",
    details = "技能冷却后，施放燃烧。需要存在有效目标。仅在技能可用时尝试执行。",
    sort = 80,
    category = "class",
    classes = {
        MAGE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_SealOfFire",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(2,17)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    if Cat2.SpellReady("燃烧") then
        CastSpellByName("燃烧")
    end

    return false
end

Cat2.RegisterCard(card)
