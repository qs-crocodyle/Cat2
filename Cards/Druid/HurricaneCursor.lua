-- 在鼠标指向的地面位置施放飓风。
local card = {
    id = "druid_hurricane_cursor",
    name = "飓风（指向）",
    description = "在鼠标指向位置施放飓风",
    details = "需要Nampower支持。技能冷却就绪时，在鼠标指向的地面位置施放飓风，无需选中目标或再次点击确认落点。仍需正常引导，并受技能自身的使用限制。当前正在引导时不重新施放，并停止本轮后续卡片，等待引导结束。尝试施放后停止本轮后续卡片；技能未就绪或当前环境不支持此功能时跳过。",
    sort = 129.3,
    category = "class",
    exclusiveGroup = "druid_hurricane",
    classes = { DRUID = 1 },
    icons = { "Interface\\Icons\\Spell_Nature_Cyclone" },
    cooldown = { type = "spell", name = "飓风" },
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
    if not Cat2.SpellReady("飓风") then
        return false
    end
    return Cat2.WithCursorQuickcast(function()
        CastSpellByNameNoQueue("飓风")
        return true
    end)
end

Cat2.RegisterCard(card)
