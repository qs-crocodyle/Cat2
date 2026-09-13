-- 在鼠标指向的地面位置施放扰乱。
local card = {
    id = "rogue_distract_cursor",
    name = "扰乱（指向）",
    description = "在鼠标指向位置施放扰乱",
    details = "需要Nampower支持。技能冷却就绪时，在鼠标指向的地面位置施放扰乱，无需选中目标或再次点击确认落点。仍受技能自身的使用限制。尝试施放后停止本轮后续卡片；技能未就绪或当前环境不支持此功能时跳过。",
    sort = 1000.1,
    category = "class",
    exclusiveGroup = "rogue_distract",
    classes = { ROGUE = 3 },
    icons = { "Interface\\Icons\\Ability_Rogue_Distract" },
    cooldown = { type = "spell", name = "扰乱" },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    if type(CastSpellByNameNoQueue) ~= "function" then
        return false
    end
    if not Cat2.SpellReady("扰乱") then
        return false
    end
    return Cat2.WithCursorQuickcast(function()
        CastSpellByNameNoQueue("扰乱")
        return true
    end)
end

Cat2.RegisterCard(card)

