-- 拦截 技能卡片。
local card = {
    id = "warrior_intercept",
    name = "拦截",
    description = "冷却时，8-25码距离施放拦截",
    details = "冷却时，8-25码距离施放拦截。需要存在有效目标。会检查目标距离。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 80,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_Sprint",
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

    if not Cat2.SetShape("狂暴姿态") then
        return false
    end

    -- 目标进入 8 码范围 不能冲锋
    if Cat2.TargetDistance("target",8) then
        return false
    end


    if player.power>=10 and Cat2.SpellReady("拦截") then
        CastSpellByName("拦截")
        return true
    end

    return false
end

Cat2.RegisterCard(card)