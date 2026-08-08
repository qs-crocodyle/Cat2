-- 复仇 技能卡片。
local card = {
    id = "warrior_revenge",
    name = "复仇",
    description = "条件满足时，施放复仇",
    details = "条件满足时，施放复仇。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 50,
    category = "class",
    classes = {
        WARRIOR = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_Revenge",
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

    if not Cat2.SetShape("防御姿态") then
        return false
    end

    if player.power>=5 and Cat2.SpellReadyOffset("复仇",1.5) and Cat2.WarriorCounterAttack() then
        CastSpellByName("复仇")
        return true
    end

end

Cat2.RegisterCard(card)