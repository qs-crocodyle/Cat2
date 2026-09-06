-- 猫鼬撕咬 技能卡片。
local card = {
    id = "hunter_mongoose_bite",
    name = "猫鼬撕咬",
    description = "目标在8码内且冷却好时，施放猫鼬撕咬",
    details = "目标在8码内且冷却好时，施放猫鼬撕咬。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 20,
    category = "class",
    classes = {
        HUNTER = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Hunter_SwiftStrike",
    },
    cooldown = {
        type = "spell",
        name = "猫鼬撕咬",
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

    -- 目标必须位于8码范围内。
    if not Cat2.TargetDistance("target", 8) then
        return false
    end

    if Cat2.SpellReady("猫鼬撕咬") then
        Cat2.Cast("猫鼬撕咬")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
