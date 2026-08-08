-- 寒冰屏障 技能卡片。
local card = {
    id = "mage_ice_block",
    name = "寒冰屏障",
    description = "生命<15%，危急时施放寒冰屏障",
    details = "生命<15%，危急时施放寒冰屏障。会检查战斗状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 90,
    category = "class",
    classes = {
        MAGE = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_Frost",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end


    if not Cat2.SpellReady("寒冰屏障") then
        return false
    end

    -- 生命值
    if player.percentHealth < 15.0 then
        CastSpellByName("寒冰屏障")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
