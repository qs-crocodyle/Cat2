-- 在鼠标指向的地面位置投掷斯坦索姆圣水。
local card = {
    id = "item_stratholme_holy_water_cursor",
    name = "斯坦索姆圣水（指向）",
    description = "在鼠标指向位置投掷斯坦索姆圣水",
    details = "需要Nampower支持。背包中有斯坦索姆圣水且物品冷却就绪时，在鼠标指向的地面位置投掷，无需选中目标或再次点击确认落点。仍受物品自身的使用限制；尝试使用后停止本轮后续卡片，物品不可用或当前环境不支持此功能时跳过。",
    sort = 1002.1,
    category = "item",
    exclusiveGroup = "stratholme_holy_water",
    canStopSequence = true,
    icons = { "Interface\\Icons\\INV_Potion_75" },
    cooldown = { type = "item", name = "斯坦索姆圣水" },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    if not Cat2.GetItemByNameCD("斯坦索姆圣水") then
        return false
    end
    return Cat2.WithCursorQuickcast(function()
        return Cat2.UseItemByName("斯坦索姆圣水")
    end, true)
end

Cat2.RegisterCard(card)
