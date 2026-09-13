-- 在鼠标指向的地面位置投掷致密炸弹。
local card = {
    id = "item_dense_dynamite_cursor",
    name = "致密炸弹（指向）",
    description = "在鼠标指向位置投掷致密炸弹",
    details = "需要Nampower支持。背包中有致密炸弹且物品冷却就绪时，在鼠标指向的地面位置投掷，无需选中目标或再次点击确认落点。仍受物品自身的使用限制；尝试使用后停止本轮后续卡片，物品不可用或当前环境不支持此功能时跳过。",
    sort = 1000.1,
    category = "item",
    exclusiveGroup = "dense_dynamite",
    canStopSequence = true,
    icons = { "Interface\\Icons\\INV_Misc_Bomb_06" },
    cooldown = { type = "item", name = "致密炸弹" },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    if not Cat2.GetItemByNameCD("致密炸弹") then
        return false
    end
    return Cat2.WithCursorQuickcast(function()
        return Cat2.UseItemByName("致密炸弹")
    end, true)
end

Cat2.RegisterCard(card)
