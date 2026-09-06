-- 卡片冷却解析服务。
--
-- 设计目的：快捷窗只负责呈现，不应猜测“卡片标题对应哪个技能”。例如“猛击（乱舞）”
-- 的真实技能名仍是“猛击”，被动卡和多技能卡更无法从标题可靠推导。因此，由卡片作者在
-- 注册定义中显式填写 cooldown，解析和游戏 API 查询统一留在本文件。
--
-- 数据边界：cooldown 只属于 Cat2.CardRegistry.ById 中的注册卡片定义。快捷窗使用流程 step.id
-- 回查注册表，不把字段复制进流程步骤，所以它不会进入 SavedVariables、配置导入或配置导出。
-- 已保存的旧配置也不需要迁移，卡片脚本更新后即可自动获得新的CD显示能力。
--
-- 支持的定义：
--   技能：cooldown = { type = "spell", name = "旋风斩" }
--   物品：cooldown = { type = "item", id = 物品数字ID }
--         或 cooldown = { type = "item", name = "物品名称" }
--   装备：cooldown = { type = "inventory", slot = 13 }
--   自定义：cooldown = { type = "custom", GetCooldown = function(step, card) ... end }
-- 自定义函数返回 startTime、duration、enabled；如果结果可被所有同卡实例安全共用，可额外提供
-- cacheKey。若结果依赖当前步骤参数，则不要提供 cacheKey，避免不同流程实例错误共用结果。
-- 自定义解析实际查询的是技能CD时，可声明 filterGlobalCooldown = true，沿用技能型的GCD过滤。
Cat2 = Cat2 or {}

-- 按名称查询物品时缓存其背包格位置，避免快捷窗每0.1秒重复扫描全部背包。
-- 未找到也缓存为 false；背包内容变化后整体清空，下一轮重新定位。
local itemLocationByNameCache = {}
-- 旧客户端返回的标准公共冷却最长为1.5秒。过滤时必须使用稳定上限，不能只依赖
-- CatEvent 按施法事件维护的 GCDMax；职业或德鲁伊形态切换期间，该状态可能暂时仍为1.0，
-- 从而让同一时刻 API 返回的1.5秒公共冷却穿透到快捷窗。
local GLOBAL_COOLDOWN_DURATION_UPPER_BOUND = 1.7
local itemLocationCacheEventFrame = CreateFrame("Frame")
itemLocationCacheEventFrame:RegisterEvent("BAG_UPDATE")
itemLocationCacheEventFrame:SetScript("OnEvent", function()
    itemLocationByNameCache = {}
end)

local function FindItemLocationByName(itemName)
    local cachedLocation = itemLocationByNameCache[itemName]
    if cachedLocation == false then
        return nil
    end
    if type(cachedLocation) == "table" then
        return cachedLocation.bag, cachedLocation.slot
    end

    local bag = 0
    while bag <= 4 do
        local slot = 1
        local slotTotal = GetContainerNumSlots(bag)
        while slot <= slotTotal do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local _, _, currentName = string.find(itemLink, "%[(.-)%]")
                if currentName == itemName then
                    itemLocationByNameCache[itemName] = {
                        bag = bag,
                        slot = slot,
                    }
                    return bag, slot
                end
            end
            slot = slot + 1
        end
        bag = bag + 1
    end

    itemLocationByNameCache[itemName] = false
    return nil
end

local function GetRegisteredCard(step)
    if type(step) ~= "table" or type(step.id) ~= "string" then
        return nil
    end
    if not Cat2.CardRegistry or not Cat2.CardRegistry.ById then
        return nil
    end
    return Cat2.CardRegistry.ById[step.id]
end

function Cat2.GetCardCooldownDefinition(step)
    local card = GetRegisteredCard(step)
    if not card or type(card.cooldown) ~= "table" then
        return nil, card
    end
    return card.cooldown, card
end

-- 同一技能可能同时出现在多个配置或多张派生卡中；缓存键让一次界面刷新只查询一次游戏 API。
-- 缓存生命周期仅限快捷窗当前刷新轮次，不缓存剩余时间，避免显示过期数据。
function Cat2.GetCardCooldownCacheKey(step)
    local definition = Cat2.GetCardCooldownDefinition(step)
    if not definition then
        return nil
    end

    local cooldownType = definition.type
    if cooldownType == "spell" and type(definition.name) == "string" then
        return "spell:" .. definition.name
    end
    if cooldownType == "item" then
        if definition.id ~= nil then
            return "item:" .. tostring(definition.id)
        end
        if type(definition.name) == "string" then
            return "item-name:" .. definition.name
        end
    end
    if cooldownType == "inventory" and definition.slot ~= nil then
        return "inventory:" .. tostring(definition.slot)
    end
    if cooldownType == "custom" then
        -- 自定义解析可能依赖每个流程步骤的参数；只有作者明确提供 cacheKey 时才跨图标复用。
        return definition.cacheKey
    end
    return nil
end

local function QuerySpellCooldown(definition)
    if type(definition.name) ~= "string" or not Cat2.GetSpellID then
        return nil
    end
    local spellBookIndex = Cat2.GetSpellID(definition.name)
    if not spellBookIndex or spellBookIndex == 0 then
        return nil
    end
    local startTime, duration, enabled = GetSpellCooldown(spellBookIndex, "spell")
    return startTime, duration, enabled, "spell"
end

local function QueryItemCooldown(definition)
    -- 旧客户端稳定支持按背包格读取冷却；名称型配置优先走这一接口。
    if type(definition.name) == "string" and type(GetContainerItemCooldown) == "function" then
        local bag, slot = FindItemLocationByName(definition.name)
        if bag ~= nil and slot ~= nil then
            local startTime, duration, enabled = GetContainerItemCooldown(bag, slot)
            return startTime, duration, enabled, "item"
        end
        -- 名称能作为有效物品定义，但背包中没有对应格子时，明确返回“物品不存在”。
        -- 快捷窗据此显示“无”，而不是把查询失败误解成物品已经冷却完成。
        return nil, nil, nil, "item", "missing_item"
    end

    -- 数字ID配置保留给支持 GetItemCooldown 的客户端或扩展模组。
    if definition.id == nil or type(GetItemCooldown) ~= "function" then
        return nil
    end

    local startTime, duration, enabled = GetItemCooldown(definition.id)
    return startTime, duration, enabled, "item"
end

local function QueryInventoryCooldown(definition)
    if type(GetInventoryItemCooldown) ~= "function" or definition.slot == nil then
        return nil
    end
    local startTime, duration, enabled = GetInventoryItemCooldown("player", definition.slot)
    return startTime, duration, enabled, "inventory"
end

local function QueryCustomCooldown(definition, step, card)
    if type(definition.GetCooldown) ~= "function" then
        return nil
    end
    local succeeded, startTime, duration, enabled = pcall(definition.GetCooldown, step, card)
    if not succeeded then
        return nil
    end
    return startTime, duration, enabled, "custom"
end

-- 统一查询入口，返回 start、duration、enabled、remaining。
-- 没有CD定义、技能未学、物品未装备或已经就绪时返回 nil，界面据此隐藏遮罩和数字。
function Cat2.QueryCardCooldown(step)
    local definition, card = Cat2.GetCardCooldownDefinition(step)
    if not definition then
        return nil
    end

    local startTime, duration, enabled, cooldownType, state
    if definition.type == "spell" then
        startTime, duration, enabled, cooldownType = QuerySpellCooldown(definition)
    elseif definition.type == "item" then
        startTime, duration, enabled, cooldownType, state = QueryItemCooldown(definition)
    elseif definition.type == "inventory" then
        startTime, duration, enabled, cooldownType = QueryInventoryCooldown(definition)
    elseif definition.type == "custom" then
        startTime, duration, enabled, cooldownType = QueryCustomCooldown(definition, step, card)
    end

    if state == "missing_item" then
        return nil, nil, nil, nil, state
    end

    if type(startTime) ~= "number" or type(duration) ~= "number" or duration <= 0 then
        return nil
    end

    local remaining = duration - (GetTime() - startTime)
    if remaining <= 0 then
        return nil
    end

    -- 旧客户端的 GetSpellCooldown 会把公共冷却当成技能CD返回，而且冷却事件可能先于 Cat2 的
    -- GCD计时器更新。若等待两套剩余时间相等再过滤，启动瞬间会闪出一次1.5秒，因此这里直接
    -- 按“总时长不超过GCD上限”过滤。极少数确有短独立CD的卡片可声明
    -- showShortCooldown = true，跳过此项过滤。
    local shouldFilterGlobalCooldown = cooldownType == "spell" or definition.filterGlobalCooldown == true
    if shouldFilterGlobalCooldown and definition.showShortCooldown ~= true then
        if duration <= GLOBAL_COOLDOWN_DURATION_UPPER_BOUND then
            return nil
        end
    end

    return startTime, duration, enabled, remaining, state
end
