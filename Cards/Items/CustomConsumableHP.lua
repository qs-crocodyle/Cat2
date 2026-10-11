-- 根据资源百分比使用自定义消耗品。
local card = {
    id = "item_custom_consumable_hp",
    name = "「自定义」消耗品（血量）",
    description = "血量低于|cff6bc7e0{triggerPercent}%|r时使用|cff6bc7e0{itemName}|r",
    details = "战斗中血量低于卡片设定值时，使用物品名称中填写的消耗品。触发值默认30%，物品名称需完整填写；名称为空、背包没有该物品或冷却未就绪时跳过。不阻断本轮后续卡片。",
    sort = 81,
    category = "item",
    icons = {
        "Interface\\Icons\\INV_Potion_49",
    },
    optionSchema = {
        {
            key = "itemName",
            type = "string",
            label = "物品名称",
            shortLabel = "物品",
            default = "",
        },
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

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    if not player.inCombat then
        return false
    end

    local itemName = context:GetStepOption(step, "itemName")
    if type(itemName) ~= "string" or itemName == "" then
        return false
    end

    local percent = context:GetStepOption(step, "triggerPercent") or 30
    if player.percentHealth < percent then
        Cat2.UseItemByName(itemName)
    end
    return false
end

Cat2.RegisterCard(card)
