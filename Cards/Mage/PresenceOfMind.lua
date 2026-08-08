-- 气定神闲 技能卡片。
local card = {
    id = "mage_presence_of_mind",
    name = "气定神闲",
    description = "技能冷却后，施放气定神闲",
    details = "技能冷却后，施放气定神闲。仅在技能可用时尝试执行。",
    sort = 110,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_EnchantArmor",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,15)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    if Cat2.SpellReadyOffset("气定神闲",1.5) and not player.buff["气定神闲"] then
        CastSpellByName("气定神闲")
    end

    return false
end

Cat2.RegisterCard(card)
