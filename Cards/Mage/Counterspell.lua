-- 法术反制 技能卡片。
local card = {
    id = "mage_counterspell",
    name = "法术反制",
    description = "目标读条时，施放法术反制",
    details = "目标读条时，施放法术反制。需要存在有效目标。仅在技能可用时尝试执行。",
    sort = 50,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_IceShock",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    if Cat2.SpellReady("法术反制") then
        CastSpellByName("法术反制")
    end


    return false
end

Cat2.RegisterCard(card)