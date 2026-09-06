-- 生命宝石饰品卡片。
local card = {
    id = "warrior_lifegiving_gem",
    name = "生命宝石",
    description = "生命低于|cff6bc7e0{triggerPercent}%|r时使用生命宝石",
    details = "战斗中生命低于卡片设定值时，使用已装备在上方或下方饰品槽的生命宝石。饰品可用时才会执行，成功执行后会阻断本轮后续卡片。",
    sort = 161,
    category = "class",
    classes = {
        WARRIOR = 3,
    },
    icons = {
        "Interface\\Icons\\INV_Misc_Gem_Pearl_05",
    },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发生命",
            shortLabel = "血",
            unit = "%",
            default = 15,
            minimum = 1,
            maximum = 99,
        },
    },
}

function card.RefreshRuntimeData()
end

-- 生命宝石是饰品，只识别已装备的上、下两个饰品槽。
local function FindLifegivingGemSlot()
    if Cat2.CheckInventoryItemName(13, "生命宝石") then
        return 13
    end
    if Cat2.CheckInventoryItemName(14, "生命宝石") then
        return 14
    end
    return nil
end

-- 生命宝石可能装备在任一饰品槽，快捷窗每次按当前实际槽位读取CD。
card.cooldown = {
    type = "custom",
    cacheKey = "inventory:lifegiving_gem",
    GetCooldown = function()
        local slot = FindLifegivingGemSlot()
        if not slot then
            return nil
        end
        return GetInventoryItemCooldown("player", slot)
    end,
}

local function IsTrinketReady(slot)
    local startTime, duration, enable = GetInventoryItemCooldown("player", slot)
    if enable ~= 1 then
        return false
    end
    if not startTime or not duration then
        return false
    end
    return duration - (GetTime() - startTime) <= 0
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 15

    if not player.inCombat or player.percentHealth >= triggerPercent then
        return false
    end

    local slot = FindLifegivingGemSlot()
    if not slot or not IsTrinketReady(slot) then
        return false
    end

    UseInventoryItem(slot)
    return true
end

Cat2.RegisterCard(card)
