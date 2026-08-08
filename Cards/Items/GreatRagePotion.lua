-- 强效怒气药水卡片。
local card = {
    id = "item_great_rage_potion",
    name = "强效怒气药水",
    description = "战士怒气<20 或 非战士冷却好 使用强效怒气药水",
    details = "战士怒气<20 或 非战士冷却好 使用强效怒气药水。会检查战斗状态。会检查当前资源。",
    sort = 120,
    category = "item",
    icons = {
        "Interface\\Icons\\inv_potion_125",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

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


    if player.classFile == "WARRIOR" then

        if player.inCombat and player.power < 20 then
            Cat2.UseItemByName("强效怒气药水")
        end

    else

        if player.inCombat then
            Cat2.UseItemByName("强效怒气药水")
        end

    end

end

Cat2.RegisterCard(card)
