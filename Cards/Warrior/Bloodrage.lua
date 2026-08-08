-- 血性狂暴 技能卡片。
local card = {
    id = "warrior_bloodrage",
    name = "血性狂暴",
    description = "怒气<30时，施放血性狂暴",
    details = "怒气<30时，施放血性狂暴。需要存在有效目标。会检查目标距离。会检查战斗状态。会检查当前资源。仅在技能可用时尝试执行。",
    sort = 140,
    category = "class",
    classes = {
        WARRIOR = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Racial_BloodRage",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.inCombat then
        return false
    end

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    -- 目标未在近战范围
    if not Cat2.TargetDistance() then
        return false
    end

    if player.power<30 and Cat2.SpellReady("血性狂暴") then
        CastSpellByName("血性狂暴")
    end

end

Cat2.RegisterCard(card)
