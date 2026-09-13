-- 在鼠标指向的地面位置施放暴风雪。
local card = {
    id = "mage_blizzard_cursor",
    name = "暴风雪（指向）",
    description = "在鼠标指向位置施放|cff6bc7e0{spellRank}级|r暴风雪",
    details = "需要Nampower支持。按卡片设定等级，在鼠标指向的地面位置施放暴风雪；默认动态使用当前已学习的最高等级。无需选中目标或再次点击确认落点，仍需正常引导，并受法力、距离及冷却等限制。当前正在引导时不重新施放，并停止本轮后续卡片，等待引导结束。尝试施放后停止本轮后续卡片；当前环境不支持此功能时跳过。",
    sort = 40.3,
    category = "class",
    exclusiveGroup = "mage_blizzard",
    classes = { MAGE = 3 },
    icons = { "Interface\\Icons\\Spell_Frost_IceStorm" },
    optionSchema = { Cat2.CreateSpellRankOption("暴风雪") },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    -- 完整保护当前引导，且阻止本轮后续卡片继续执行。
    if Cat2.GetChanneled() > 0 then
        return true
    end
    if type(CastSpellByNameNoQueue) ~= "function" then
        return false
    end
    local spellRank = context:GetStepOption(step, "spellRank")
    local spellName = Cat2.GetRankedSpellName("暴风雪", spellRank) or "暴风雪"
    return Cat2.WithCursorQuickcast(function()
        if Cat2.RecordMageChannelCast then
            Cat2.RecordMageChannelCast(spellName)
        end
        CastSpellByNameNoQueue(spellName)
        return true
    end)
end

Cat2.RegisterCard(card)
