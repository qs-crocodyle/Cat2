-- 在鼠标指向的地面位置投掷指定消耗品。
local card = {
    id = "item_custom_cast_consumable_cursor",
    name = "「自定义」施放消耗品（指向）",
    description = "在鼠标指向位置投掷|cff6bc7e0{itemName}|r",
    details = "填写消耗品完整名称，名称为空时跳过。需要Nampower支持。背包中有指定消耗品且物品冷却就绪时，在鼠标指向的地面位置投掷，无需选中目标或再次点击确认落点。仍受物品自身的使用限制；尝试使用后停止本轮后续卡片，物品不可用或当前环境不支持此功能时跳过。",
    sort = 1005,
    category = "item",
    canStopSequence = true,
    icons = { "Interface\\Icons\\INV_Misc_Bomb_04" },
    optionSchema = {
        {
            key = "itemName",
            type = "string",
            label = "物品名称",
            shortLabel = "物品",
            default = "",
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local itemName = context:GetStepOption(step, "itemName")
    if type(itemName) ~= "string" or itemName == "" then
        return false
    end
    if not Cat2.GetItemByNameCD(itemName) then
        return false
    end
    return Cat2.WithCursorQuickcast(function()
        return Cat2.UseItemByName(itemName)
    end, true)
end

Cat2.RegisterCard(card)
