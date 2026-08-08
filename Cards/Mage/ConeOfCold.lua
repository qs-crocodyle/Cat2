-- 冰锥术 技能卡片。
local card = {
    id = "mage_cone_of_cold",
    name = "冰锥术",
    description = "有效距离内，冷却后施放冰锥术",
    details = "有效距离内，冷却后施放冰锥术。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 40,
    category = "class",
    classes = {
        MAGE = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_Glacier",
    },
}

local range = 8

function card.RefreshRuntimeData()
    allowUse = 8 + Cat2.IsTalentLearned(3,11)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    -- 有效射程
    if not Cat2.TargetDistance("target", range) then
        return false
    end

    if Cat2.SpellReady("冰锥术") then  -- 可以增加保护 not player.buff["冰霜速冻"]
        CastSpellByName("冰锥术")
        return true
    end

    return false

end

Cat2.RegisterCard(card)