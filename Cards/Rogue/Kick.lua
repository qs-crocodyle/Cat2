-- 脚踢 技能卡片。
local card = {
    id = "rogue_kick",
    name = "脚踢",
    description = "目标读条时，施放脚踢，需SuperWoW模组",
    details = "目标读条时，施放脚踢，需SuperWoW模组。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 50,
    category = "class",
    classes = {
        ROGUE = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Kick",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 确认目标正在读条
    local cast,name = Cat2.TargetCast()
    if not cast then
        return false
    end

    if player.power>=25 and Cat2.SpellReady("脚踢") then
        CastSpellByName("脚踢")
        return true
    end

    return false

end

Cat2.RegisterCard(card)