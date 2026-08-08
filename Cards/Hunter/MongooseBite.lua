-- 猫鼬撕咬 技能卡片。
local card = {
    id = "hunter_mongoose_bite",
    name = "猫鼬撕咬",
    description = "冷却好时，施放猫鼬撕咬",
    details = "冷却好时，施放猫鼬撕咬。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 20,
    category = "class",
    classes = {
        HUNTER = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Hunter_SwiftStrike",
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

    if Cat2.SpellReady("猫鼬撕咬") then
        CastSpellByName("猫鼬撕咬")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
