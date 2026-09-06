-- 魔甲术技能卡片。
local card = {
    id = "warlock_demon_armor",
    name = "魔甲术",
    description = "没有魔甲术效果时施放魔甲术",
    details = "玩家身上没有魔甲术增益时施放魔甲术，用于保持自身护甲效果。",
    sort = 50.1,
    category = "class",
    classes = { WARLOCK = 2 },
    icons = { "Interface\\Icons\\Spell_Shadow_RagingScream" },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    if not Cat2.PlayerInformation.temporary.buff["魔甲术"] then
        Cat2.Cast("魔甲术")
    end

    return false
end

Cat2.RegisterCard(card)
