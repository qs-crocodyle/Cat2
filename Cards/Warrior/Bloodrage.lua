-- 血性狂暴 技能卡片。
local card = {
    id = "warrior_bloodrage",
    name = "血性狂暴",
    description = "怒气低于|cff6bc7e0{maximumRage}|r时施放血性狂暴",
    details = "怒气低于卡片设定值时施放血性狂暴。需要存在有效目标。会检查目标距离。会检查战斗状态。会检查当前资源。仅在技能可用时尝试执行。",
    sort = 140,
    category = "class",
    classes = {
        WARRIOR = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Racial_BloodRage",
    },
    cooldown = {
        type = "spell",
        name = "血性狂暴",
    },
    optionSchema = {
        {
            key = "maximumRage",
            type = "number",
            label = "最高怒气",
            shortLabel = "怒",
            default = 30,
            minimum = 1,
            maximum = 100,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local maximumRage = context:GetStepOption(step, "maximumRage") or 30

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

    if player.power<maximumRage and Cat2.SpellReady("血性狂暴") then
        Cat2.Cast("血性狂暴")
    end

end

Cat2.RegisterCard(card)
