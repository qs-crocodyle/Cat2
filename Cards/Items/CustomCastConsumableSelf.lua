-- 指定消耗品（自己）消耗品卡片。
-- 使用与致密炸弹（自己）相同的 UnitXP 定点投掷机制。
local card = {
    id = "item_custom_cast_consumable_self",
    name = "「自定义」施放消耗品（自己）",
    description = "以自己为投掷位置使用|cff6bc7e0{itemName}|r，需UnitXP202607以上",
    details = "填写消耗品完整名称，名称为空时跳过。物品冷却完成时，以自己为投掷位置使用指定消耗品。需要 UnitXP 202607 以上版本支持；成功执行时会阻断本轮后续卡片。",
    sort = 1003,
    category = "item",
    canStopSequence = true,
    icons = {
        "Interface\\Icons\\INV_Misc_Bomb_04",
    },
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

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = 0

    if Cat2.UnitXP then

        local compileTime = UnitXP("version", "coffTimeDateStamp")
        if compileTime >= 1782864000 then
            allowUse = 1
        end

    end

end

function card.Execute(context, step)
    local itemName = context:GetStepOption(step, "itemName")
    if type(itemName) ~= "string" or itemName == "" then
        return false
    end

    if allowUse == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff8000当前UnitXP模块版本不支持！|r")
        return false
    end

    if not Cat2.GetItemByNameCD(itemName) then
        return false
    end

    if Cat2.UseItemByName(itemName) then
        UnitXP("castAOE", "player")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
