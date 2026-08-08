-- 破釜沉舟 技能卡片。
local card = {
    id = "warrior_last_stand",
    name = "破釜沉舟",
    description = "生命<15%，危急时施放破釜沉舟",
    details = "生命<15%，危急时施放破釜沉舟。会检查战斗状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 160,
    category = "class",
    classes = {
        WARRIOR = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_AshesToAshes",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.inCombat then
        return false
    end


    if not Cat2.SpellReady("破釜沉舟") then
        return false
    end

    if player.percentHealth < 15.0 then
        CastSpellByName("破釜沉舟")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
