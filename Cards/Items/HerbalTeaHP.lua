-- 草药茶卡片之一；与同名卡片使用不同 ID，方便后续分别扩展条件。
local card = {
    id = "item_herbal_tea_hp",
    name = "草药茶（血量）",
    description = "血量低于|cff6bc7e0{triggerPercent}%|r时使用草药茶",
    details = "战斗中血量低于卡片设定值时，依次尝试使用可用的草药茶。未单独设置时使用默认值30%。",
    sort = 10,
    category = "item",
    icons = {
        "Interface\\Icons\\inv_drink_waterskin_03",
        "Interface\\Icons\\INV_Drink_15",
    },
    cooldown = {
        type = "item",
        name = "诺达纳尔草药茶",
    },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发血量",
            unit = "%",
            default = 30,
            minimum = 1,
            maximum = 99,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local percent = context:GetStepOption(step, "triggerPercent") or 30
    local player = Cat2.PlayerInformation.temporary

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end

    if player.inCombat and player.percentHealth<percent then
		Cat2.UseItemByName("糖水茶")
		Cat2.UseItemByName("诺达纳尔草药茶")
    end

end

Cat2.RegisterCard(card)
