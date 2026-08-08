-- 圣盾术 技能卡片。
local card = {
    id = "paladin_divine_shield",
    name = "圣盾术",
    description = "生命<15%，危急时施放圣盾术",
    details = "生命<15%，危急时施放圣盾术。会检查战斗状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 130,
    category = "class",
    classes = {
        PALADIN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_DivineIntervention",
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


    if not Cat2.SpellReady("圣盾术") then
        return false
    end

    -- 生命值
    if player.percentHealth < 15.0 and not player.buff["自律"] then
        CastSpellByName("圣盾术")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
