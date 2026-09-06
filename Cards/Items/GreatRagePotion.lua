-- 强效怒气药水卡片。
local card = {
    id = "item_great_rage_potion",
    name = "强效怒气药水",
    description = "战士怒气低于|cff6bc7e0{maximumRage}|r时使用强效怒气药水",
    details = "战士怒气低于卡片设定值时使用强效怒气药水；非战士在战斗中冷却恢复时尝试使用。会检查战斗状态。会检查当前资源。",
    sort = 120,
    category = "item",
    icons = {
        "Interface\\Icons\\inv_potion_125",
    },
    cooldown = {
        type = "item",
        name = "强效怒气药水",
    },
    optionSchema = {
        {
            key = "maximumRage",
            type = "number",
            label = "最高怒气",
            shortLabel = "怒",
            default = 20,
            minimum = 1,
            maximum = 100,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local maximumRage = context:GetStepOption(step, "maximumRage") or 20

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end

    local boss = context and context.parameters and context.parameters.burstOnlyBoss
    if boss then
        if not Cat2.IsBossTarget() then
            return false
        end
    end

    local melee = context and context.parameters and context.parameters.burstOnlyMelee
    if melee and not Cat2.TargetDistance() then
        return false
    end


    if player.classFile == "WARRIOR" then

        if player.inCombat and player.power < maximumRage then
            Cat2.UseItemByName("强效怒气药水")
        end

    else

        if player.inCombat then
            Cat2.UseItemByName("强效怒气药水")
        end

    end

end

Cat2.RegisterCard(card)
