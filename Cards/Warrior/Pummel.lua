-- 拳击 技能卡片。
local card = {
    id = "warrior_pummel",
    name = "拳击",
    description = "目标读条时，施放拳击，需SuperWoW模组",
    details = "目标读条时，施放拳击，需SuperWoW模组。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 150,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\INV_Gauntlets_04",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if not Cat2.PlayerInformation.temporary.buff["狂暴姿态"] and not Cat2.PlayerInformation.temporary.buff["武器姿态"] then
        return false
    end

    -- 确认目标正在读条。
    local cast, name = Cat2.TargetCast()
    if not cast then
        return false
    end

    if player.power >= 10 and Cat2.SpellReady("拳击") then
        CastSpellByName("拳击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
