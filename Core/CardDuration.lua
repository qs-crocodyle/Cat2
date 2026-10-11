-- 卡片持续时间显示服务：独立于技能冷却，不创建事件框架或维护第二套计时。
-- 定义只保存在注册卡片上，不进入流程存档或导入导出。
-- duration = { type = "custom", GetDuration = function(step, card) return start, duration end }
-- 或注册提供者后使用 duration = { type = "提供者名", ...提供者参数... }。
-- 提供者接收 definition、step、card，返回起点和总时长（秒）；无效果时返回 nil。
-- 可选 cacheKey 只用于同一轮显示刷新；依赖步骤参数的定义不要设置共享缓存键。
Cat2 = Cat2 or {}
local providers = {}

function Cat2.RegisterCardDurationProvider(name, query)
    if type(name) == "string" and name ~= "custom" and type(query) == "function" then
        providers[name] = query
    end
end

function Cat2.GetCardDurationDefinition(step)
    local registry = Cat2.CardRegistry and Cat2.CardRegistry.ById
    local card = type(step) == "table" and registry and registry[step.id]
    if card and type(card.duration) == "table" then return card.duration, card end
    return nil
end

function Cat2.GetCardDurationCacheKey(step)
    local definition = Cat2.GetCardDurationDefinition(step)
    if definition and type(definition.cacheKey) == "string" then return definition.cacheKey end
    return nil
end

function Cat2.QueryCardDuration(step)
    local definition, card = Cat2.GetCardDurationDefinition(step)
    if not definition then return nil end
    local ok, startTime, duration
    if definition.type == "custom" and type(definition.GetDuration) == "function" then
        ok, startTime, duration = pcall(definition.GetDuration, step, card)
    elseif providers[definition.type] then
        ok, startTime, duration = pcall(providers[definition.type], definition, step, card)
    end
    if not ok or type(startTime) ~= "number" or type(duration) ~= "number"
        or startTime ~= startTime or duration ~= duration or duration <= 0 then return nil end
    local remaining = startTime + duration - GetTime()
    if remaining <= 0 or remaining > duration then return nil end
    return startTime, duration, remaining
end
