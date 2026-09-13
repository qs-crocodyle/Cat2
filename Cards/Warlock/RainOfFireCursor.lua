-- 在鼠标指向的地面位置施放火焰之雨。
local card = {
    id = "warlock_rain_of_fire_cursor",
    name = "火焰之雨（指向）",
    description = "在鼠标指向位置施放火焰之雨",
    details = "需要Nampower支持。在鼠标指向的地面位置施放火焰之雨，无需选中目标或再次点击确认落点。仍需正常引导，并受技能自身的使用限制。当前正在引导时不重新施放，并停止本轮后续卡片，等待引导结束。尝试施放后停止本轮后续卡片；当前环境不支持此功能时跳过。",
    sort = 40.3,
    category = "class",
    exclusiveGroup = "warlock_rain_of_fire",
    classes = { WARLOCK = 3 },
    icons = { "Interface\\Icons\\Spell_Shadow_RainOfFire" },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    -- 完整保护当前引导，且阻止本轮后续卡片继续执行。
    if Cat2.GetChanneled() > 0 then
        return true
    end
    if type(CastSpellByNameNoQueue) ~= "function" then
        return false
    end
    return Cat2.WithCursorQuickcast(function()
        if Cat2.RecordWarlockChannelCast then
            Cat2.RecordWarlockChannelCast("火焰之雨")
        end
        CastSpellByNameNoQueue("火焰之雨")
        return true
    end)
end

Cat2.RegisterCard(card)
