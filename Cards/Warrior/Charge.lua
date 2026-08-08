-- 冲锋 技能卡片。
local card = {
    id = "warrior_charge",
    name = "冲锋",
    description = "未进入战斗时，8-25码距离施放冲锋",
    details = "未进入战斗时，8-25码距离施放冲锋。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 20,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_Charge",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    if not Cat2.SetShape("战斗姿态") then
        return false
    end

    -- 战斗中不能冲锋
    if player.imCombat then
        return false
    end

    -- 目标进入 8 码范围 不能冲锋
    if Cat2.TargetDistance("target",8) then
        return false
    end


    if Cat2.SpellReady("冲锋") then
        CastSpellByName("冲锋")
        return true
    end

    return false
end

Cat2.RegisterCard(card)