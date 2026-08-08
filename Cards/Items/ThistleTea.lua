-- 菊花茶卡片。
local card = {
    id = "item_thistle_tea",
    name = "菊花茶",
    description = "能量<15 使用菊花茶，仅限盗贼",
    details = "能量<15 使用菊花茶，仅限盗贼。会检查战斗状态。会检查当前资源。",
    sort = 100,
    category = "item",
    icons = {
        "Interface\\Icons\\INV_Drink_Milk_05",
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


    if Cat2.PlayerInformation.basic.classFile == "ROGUE" then

        if player.power < 15 then
            Cat2.UseItemByName("菊花茶")
        end

    end

end

Cat2.RegisterCard(card)
