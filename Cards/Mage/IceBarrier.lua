-- 寒冰护体 技能卡片。
local card = {
    id = "mage_ice_barrier",
    name = "寒冰护体",
    description = "冷却后，施放寒冰护体",
    details = "冷却后，施放寒冰护体。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 41,
    category = "class",
    classes = {
        MAGE = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Ice_Lament",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(3,19)
end

function card.Execute(context)


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end


    if Cat2.SpellReady("寒冰护体") then
        CastSpellByName("寒冰护体")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
