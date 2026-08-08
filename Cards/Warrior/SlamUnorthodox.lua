-- 猛击（邪修）技能卡片；执行逻辑与原猛击卡保持一致。
local card = {
    id = "warrior_slam_unorthodox",
    name = "猛击（邪修）",
    description = "无视普攻，普攻周期的>0.5秒，施放猛击",
    details = "无视普攻，普攻周期的>0.5秒，施放猛击。需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 115,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_DecisiveStrike_New",
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

    if player.power >= 15 and Cat2.GetMainHandLeft() > 0.5 then
        Cat2.CastWithoutNampower("猛击")
        return true
    end
end

Cat2.RegisterCard(card)
