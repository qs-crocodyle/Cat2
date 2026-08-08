-- 毒蛇钉刺 技能卡片。
local card = {
    id = "hunter_serpent_sting",
    name = "毒蛇钉刺",
    description = "施放毒蛇钉刺",
    details = "施放毒蛇钉刺。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 60,
    category = "class",
    exclusiveGroup = "hunter_sting",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Hunter_Quickshot",
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


    if not Cat2.GetSerpentStingDot() then
        CastSpellByName("毒蛇钉刺")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
