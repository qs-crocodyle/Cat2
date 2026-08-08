-- 致死打击 技能卡片。
local card = {
    id = "warrior_mortal_strike",
    name = "致死打击",
    description = "冷却好时，施放致死打击",
    details = "冷却好时，施放致死打击。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 100,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_SavageBlow",
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

    if player.power>=30 and Cat2.SpellReady("致死打击") then
        CastSpellByName("致死打击")
        return true
    end

end

Cat2.RegisterCard(card)