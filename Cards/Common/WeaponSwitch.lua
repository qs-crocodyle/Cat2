-- 根据完整物品名称分别切换主手、副手装备。
local card = {
    id = "common_weapon_switch",
    name = "「自定义」武器切换",
    description = "主手装备|cff6bc7e0{mainHandWeapon}|r，副手装备|cff6bc7e0{offHandWeapon}|r",
    details = "按完整物品名称切换主手和副手装备。对应槽位已经装备该物品时不重复切换；参数留空则保留该槽位，背包中没有指定物品时跳过。不阻断本轮后续卡片。",
    -- 位于“自动交互”之前。
    sort = 49,
    category = "common",
    icons = {
        "Interface\\Icons\\INV_Sword_39",
    },
    optionSchema = {
        {
            key = "mainHandWeapon",
            type = "string",
            label = "主手武器",
            shortLabel = "主手",
            default = "",
        },
        {
            key = "offHandWeapon",
            type = "string",
            label = "副手武器",
            shortLabel = "副手",
            default = "",
        },
    },
}

local function EquipWeaponIfNeeded(itemName, inventorySlot)
    if type(itemName) ~= "string" or itemName == "" then
        return
    end

    -- 不占用玩家正在拖放的物品，也不覆盖前一次装备失败留在游标上的物品。
    if CursorHasItem and CursorHasItem() then
        return
    end

    local itemLink = GetInventoryItemLink("player", inventorySlot)
    if itemLink then
        local _, _, equippedName = string.find(itemLink, "%[(.-)%]")
        if equippedName == itemName then
            return
        end
    end

    Cat2.EquipItemByName(itemName, inventorySlot)
end

function card.Execute(context, step)
    EquipWeaponIfNeeded(context:GetStepOption(step, "mainHandWeapon"), 16)
    EquipWeaponIfNeeded(context:GetStepOption(step, "offHandWeapon"), 17)
    return false
end

Cat2.RegisterCard(card)
