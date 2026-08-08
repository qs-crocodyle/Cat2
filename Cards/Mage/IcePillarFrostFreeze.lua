-- 冰柱（冰霜速冻）技能卡片；执行逻辑与冰柱一致。
local card = {
    id = "mage_ice_pillar_frost_freeze",
    name = "冰柱（冰霜速冻）",
    description = "触发冰霜速冻时，施放冰柱",
    details = "触发冰霜速冻时，施放冰柱。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 12,
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

    if player.buff["冰霜速冻"] and Cat2.SpellReady("冰柱") then
        CastSpellByName("冰柱")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
