-- 蝰蛇钉刺 技能卡片。
local card = {
    id = "hunter_viper_sting",
    name = "蝰蛇钉刺",
    description = "施放并保持蝰蛇钉刺",
    details = "施放并保持蝰蛇钉刺。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 70,
    category = "class",
    exclusiveGroup = "hunter_sting",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Hunter_AimedShot",
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


    if not Cat2.GetViperStingDot() then
        CastSpellByName("蝰蛇钉刺")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
