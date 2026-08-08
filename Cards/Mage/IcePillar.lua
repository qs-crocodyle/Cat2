-- 冰柱 技能卡片。
local card = {
    id = "mage_ice_pillar",
    name = "冰柱",
    description = "冷却后，施放冰柱",
    details = "冷却后，施放冰柱。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 11,
    category = "class",
    classes = {
        MAGE = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_FrostBlast",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(3,15)
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

    if Cat2.SpellReady("冰柱") then
        CastSpellByName("冰柱")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
