-- 驱散射击技能卡片。
local card = {
    id = "hunter_scatter_shot",
    name = "驱散射击",
    description = "目标距离不低于8码且技能就绪时，施放驱散射击",
    details = "目标距离不低于8码且技能就绪时，施放驱散射击。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 57,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_GolemStormBolt",
    },
    cooldown = {
        type = "spell",
        name = "驱散射击",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance < 8 then
            return false
        end
    end

    if Cat2.SpellReady("驱散射击") then
        Cat2.Cast("驱散射击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
