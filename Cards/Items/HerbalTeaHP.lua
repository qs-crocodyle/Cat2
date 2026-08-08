-- 草药茶卡片之一；与同名卡片使用不同 ID，方便后续分别扩展条件。
local card = {
    id = "item_herbal_tea_hp",
    name = "草药茶（血量）",
    description = "血量<30% 使用草药茶",
    details = "血量<30% 使用草药茶。会检查战斗状态。",
    sort = 10,
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


    if player.inCombat and player.percentHealth<percent then
		Cat2.UseItemByName("糖水茶")
		Cat2.UseItemByName("诺达纳尔草药茶")
    end

end

Cat2.RegisterCard(card)
