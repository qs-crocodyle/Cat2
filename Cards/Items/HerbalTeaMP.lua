-- 草药茶卡片之二；保留为独立卡片和独立流程位置。
local card = {
    id = "item_herbal_tea_mp",
    name = "草药茶（蓝量）",
    description = "蓝量<30% 使用草药茶",
    details = "蓝量<30% 使用草药茶。会检查战斗状态。",
    sort = 20,
    category = "item",
    icons = {
        "Interface\\Icons\\inv_drink_waterskin_03",
        "Interface\\Icons\\INV_Drink_15",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local percent = 30
    local player = Cat2.PlayerInformation.temporary

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end

    local p = context and context.parameters and context.parameters.recoveryPercent
    if p then
        percent = p
    end

    if player.inCombat and player.percentMana<percent then
		Cat2.UseItemByName("糖水茶")
		Cat2.UseItemByName("诺达纳尔草药茶")
    end

end

Cat2.RegisterCard(card)
