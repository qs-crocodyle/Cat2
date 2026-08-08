-- 加速药水卡片。
local card = {
    id = "item_haste_potion",
    name = "加速药水",
    description = "冷却好后，使用加速药水",
    details = "冷却好后，使用加速药水。会检查战斗状态。",
    sort = 130,
    category = "item",
    icons = {
        "Interface\\Icons\\INV_Potion_08",
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


    if player.inCombat then
        Cat2.UseItemByName("加速药水")
    end

end

Cat2.RegisterCard(card)
