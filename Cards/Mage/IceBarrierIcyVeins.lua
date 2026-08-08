-- 寒冰护体（冰冷血脉）技能卡片；执行机制与原寒冰护体一致。
local card = {
    id = "mage_ice_barrier_icy_veins",
    name = "寒冰护体（冰冷血脉）",
    description = "冰冷血脉消失后，施放寒冰护体",
    details = "冰冷血脉消失后，施放寒冰护体。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 42,
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

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    if Cat2.SpellReady("寒冰护体") and not player.buff["冰冷血脉"] then
        CastSpellByName("寒冰护体")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
