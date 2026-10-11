-- 毒药卡共用的武器附魔检查与涂抹入口；独立于 CatPotion。
Cat2 = Cat2 or {}

-- 所有职业都注册卡片定义，支持切换职业预览。
function Cat2.CreateWeaponPoisonCard(id, itemName, weaponSlot, sort, icon)
    local hand = weaponSlot == 16 and "主手" or "副手"
    local card = {
        id = id,
        name = itemName .. "（" .. hand .. "）",
        description = hand .. "毒药少于|cff6bc7e0{minimumCharges}次|r或|cff6bc7e0{minimumSeconds}秒|r时补涂",
        details = "检查" .. hand .. "武器的" .. itemName .. "。未附有该毒药，或剩余次数、剩余时间任一低于设定值时，使用背包中的同名毒药补涂；会替换该手原有临时附魔。未装备武器、读条中、物品锁定或冷却时跳过。默认20次、60秒。未知次数不当作0次。旧客户端附魔提示不含等级时按毒药类型识别。发出涂抹请求后结束本轮流程。",
        category = "class",
        classes = { ROGUE = 4 },
        exclusiveGroup = weaponSlot == 16 and "rogue_poison_main" or "rogue_poison_off",
        sort = sort,
        canStopSequence = true,
        icons = { icon or "Interface\\Icons\\INV_Potion_19" },
        optionSchema = {
            { key = "minimumCharges", type = "number", label = "剩余次数", shortLabel = "次数", unit = "次", default = 20, minimum = 0, maximum = 1000 },
            { key = "minimumSeconds", type = "number", label = "剩余时间", shortLabel = "时间", unit = "秒", default = 60, minimum = 0, maximum = 3600 },
        },
    }
    function card.Execute(context, step)
        return Cat2.TryApplyWeaponPoison(itemName, weaponSlot,
            context:GetStepOption(step, "minimumCharges") or 20,
            context:GetStepOption(step, "minimumSeconds") or 60)
    end
    Cat2.RegisterCard(card)
end

-- 只有盗贼初始化上毒监测和事件；其他职业的执行入口直接跳过。
local _, playerClass = UnitClass("player")
if playerClass ~= "ROGUE" then
    function Cat2.TryApplyWeaponPoison() return false end
    return
end

local tooltip = CreateFrame("GameTooltip", "Cat2WeaponPoisonTooltip", UIParent, "GameTooltipTemplate")
local pendingApplication
local applicationFrame = CreateFrame("Frame")
applicationFrame:RegisterEvent("SPELLCAST_START")
applicationFrame:RegisterEvent("SPELLCAST_STOP")
applicationFrame:RegisterEvent("SPELLCAST_FAILED")
applicationFrame:RegisterEvent("SPELLCAST_INTERRUPTED")
applicationFrame:SetScript("OnEvent", function()
    if not pendingApplication then return end
    if event == "SPELLCAST_START" then
        pendingApplication.sawCast = true
        pendingApplication.expires = GetTime() + (tonumber(arg2) or 0) / 1000 + 8
    elseif event == "SPELLCAST_STOP" then
        -- 读条结束后，武器附魔信息可能晚一帧或数帧才更新。
        pendingApplication.releaseAt = GetTime() + 1
    elseif event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" then
        pendingApplication = nil
    end
end)

local function IsApplicationPending()
    if not pendingApplication then return false end
    local now = GetTime()
    if Cat2.GetIsCast() then
        pendingApplication.sawCast = true
    elseif pendingApplication.sawCast and not pendingApplication.releaseAt then
        -- 即使遗漏结束事件，也从首次观察到读条结束开始等待。
        pendingApplication.releaseAt = now + 1
    end
    if now >= (pendingApplication.releaseAt or pendingApplication.expires) then
        pendingApplication = nil
        return false
    end
    return true
end

local function ApplyToWeapon(bag, bagSlot, weaponSlot)
    UseContainerItem(bag, bagSlot, false)
    if not SpellIsTargeting() then return false end
    PickupInventoryItem(weaponSlot)
    if type(ReplaceEnchant) == "function" then
        ReplaceEnchant()
    elseif StaticPopup1 and StaticPopup1:IsVisible() and StaticPopup1.which == "REPLACE_ENCHANT"
        and StaticPopup1Button1 then
        StaticPopup1Button1:Click()
    end
    ClearCursor()
    return true
end

local function ReadPoison(slot, itemName, apiCharges)
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:ClearLines()
    tooltip:SetInventoryItem("player", slot)
    local matched, charges = false, nil
    local baseName = string.gsub(itemName, "%s+[IVX]+$", "")
    -- enUS 附魔提示为英文名；经本地化取英文基名做双匹配，zhCN 原样返回。
    local enBaseName = baseName
    if Cat2.L and Cat2.L.Spell then enBaseName = Cat2.L.Spell(baseName) end
    local _, _, rank = string.find(itemName, "%s+([IVX]+)$")
    local expectedRank = rank
    for index = 2, tooltip:NumLines() do
        local line = getglobal("Cat2WeaponPoisonTooltipTextLeft" .. index)
        local text = line and line:GetText() or ""
        text = string.gsub(string.gsub(text, "|c%x%x%x%x%x%x%x%x", ""), "|r", "")
        local startIndex, endIndex = string.find(text, baseName, 1, true)
        if not startIndex and enBaseName ~= baseName then
            startIndex, endIndex = string.find(text, enBaseName, 1, true)
        end
        if startIndex then
            local suffix = string.sub(text, endIndex + 1)
            local _, _, actualRank = string.find(suffix, "^%s*([IVX]+)")
            -- 旧客户端的附魔提示可能只显示毒药类型；有等级时必须精确匹配。
            if not actualRank or actualRank == expectedRank then
                matched = true
                local _, _, value = string.find(suffix, "(%d+)%s*次")
                if not value then
                    local _, _, enValue = string.find(suffix, "(%d+)%s*[Cc]harges?")
                    value = enValue
                end
                charges = tonumber(value)
                break
            end
        end
    end
    tooltip:Hide()
    if charges == nil and tonumber(apiCharges) and tonumber(apiCharges) > 0 then
        charges = tonumber(apiCharges)
    end
    return matched, charges
end

function Cat2.TryApplyWeaponPoison(itemName, weaponSlot, minimumCharges, minimumSeconds)
    -- 主副手共享等待状态；返回 true 结束本轮，避免排入下一次涂抹。
    if IsApplicationPending() then return true end
    if not GetInventoryItemLink("player", weaponSlot) then return false end
    if Cat2.GetIsCast() or Cat2.CheckUIStatus() then return false end
    if (type(CursorHasItem) == "function" and CursorHasItem()) or SpellIsTargeting() then return false end

    local hasMain, mainTime, mainCharges, hasOff, offTime, offCharges = GetWeaponEnchantInfo()
    local present, milliseconds, apiCharges = hasMain, mainTime, mainCharges
    if weaponSlot == 17 then present, milliseconds, apiCharges = hasOff, offTime, offCharges end
    if present and present ~= 0 then
        local matched, charges = ReadPoison(weaponSlot, itemName, apiCharges)
        local seconds = tonumber(milliseconds) and tonumber(milliseconds) / 1000 or nil
        if matched and not (charges and charges < minimumCharges) and not (seconds and seconds < minimumSeconds) then
            return false
        end
    end

    -- enUS 背包链接为英文名；全名（含等级后缀）同样经本地化做双匹配。
    local enItemName = itemName
    if Cat2.L and Cat2.L.Spell then enItemName = Cat2.L.Spell(itemName) end
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            local _, _, name = string.find(link or "", "%[(.-)%]")
            if name == itemName or name == enItemName then
                local _, count, locked = GetContainerItemInfo(bag, slot)
                local startTime, duration, enabled = GetContainerItemCooldown(bag, slot)
                if locked ~= true and locked ~= 1 and (count or 0) > 0 and enabled ~= 0
                    and ((duration or 0) <= 0 or (startTime or 0) + duration <= GetTime()) then
                    pendingApplication = { expires = GetTime() + 8 }
                    local applied = ApplyToWeapon(bag, slot, weaponSlot)
                    if not applied then pendingApplication = nil end
                    return applied
                end
            end
        end
    end
    return false
end
