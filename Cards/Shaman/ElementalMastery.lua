-- 元素掌握 技能卡片。
local card = {
    id = "shaman_elemental_mastery",
    name = "元素掌握",
    description = "冷却时，施放元素掌握",
    details = "冷却时，施放元素掌握。需要存在有效目标。仅在技能可用时尝试执行。",
    sort = 70,
    category = "class",
    classes = {
        SHAMAN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_WispHeal",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1, 14)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    -- 未学习元素掌握天赋时不执行。
    if allowUse == 0 then
        return false
    end

    if Cat2.SpellReady("元素掌握") then
        CastSpellByName("元素掌握")
    end

    return false
end

Cat2.RegisterCard(card)
