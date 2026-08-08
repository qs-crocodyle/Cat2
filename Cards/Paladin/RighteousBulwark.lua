-- 圣骑士防护系：正义壁垒。
local card = {
    id = "paladin_righteous_bulwark",
    name = "正义壁垒",
    description = "生命<30%时施放正义壁垒",
    details = "生命<30%时施放正义壁垒。需要存在有效目标。会检查战斗状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 110,
    category = "class",
    classes = {
        PALADIN = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_VictoryRush",
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

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end

    -- 必须有盾牌
    if not Cat2.IsOffHandShield() then
        return false
    end


    if not Cat2.SpellReady("正义壁垒") then
        return false
    end

    if player.percentHealth < 30.0 then
        CastSpellByName("正义壁垒")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
