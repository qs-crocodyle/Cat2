-- 盾牌格挡 技能卡片。
local card = {
    id = "warrior_shield_block",
    name = "盾牌格挡",
    description = "保持强化格挡，施放盾牌格挡",
    details = "保持强化格挡，施放盾牌格挡。会检查目标距离。会检查战斗状态。仅在技能可用时尝试执行。",
    sort = 30,
    category = "class",
    classes = {
        WARRIOR = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Defend",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.inCombat then
        return false
    end


    if not Cat2.SpellReady("盾牌格挡") then
        return false
    end

    -- 目标未在 8 码范围
    if not Cat2.TargetDistance("target",7) then
        return false
    end

    -- 必须有盾牌
    if not Cat2.IsOffHandShield() then
        return false
    end


    if not player.buff["强化盾牌猛击"] and not player.buff["盾牌格挡"] then
        CastSpellByName("盾牌格挡")
    end

    return falseend
end

Cat2.RegisterCard(card)