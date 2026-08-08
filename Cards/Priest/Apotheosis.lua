-- 超凡入圣技能卡片。
local card = {
    id = "priest_apotheosis",
    name = "超凡入圣",
    description = "技能冷却后，施放超凡入圣",
    details = "技能冷却后，施放超凡入圣。仅在技能可用时尝试执行。",
    sort = 140,
    category = "class",
    classes = {
        PRIEST = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_SurgeofLight",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(2,17)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    if Cat2.SpellReady("超凡入圣") then
        CastSpellByName("超凡入圣")
    end

    return false
end

Cat2.RegisterCard(card)

