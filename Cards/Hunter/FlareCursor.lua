-- 在鼠标指向的地面位置施放照明弹。
local card = {
    id = "hunter_flare_cursor",
    name = "照明弹（指向）",
    description = "在鼠标指向位置施放照明弹",
    details = "需要Nampower支持。技能冷却就绪时，在鼠标指向的地面位置施放照明弹，无需选中目标或再次点击确认落点。仍受技能自身的使用限制。尝试施放后停止本轮后续卡片；技能未就绪或当前环境不支持此功能时跳过。",
    sort = 1000.1,
    category = "class",
    exclusiveGroup = "hunter_flare",
    classes = { HUNTER = 2 },
    icons = { "Interface\\Icons\\Spell_Fire_Flare" },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    if type(CastSpellByNameNoQueue) ~= "function" then
        return false
    end
    if not Cat2.SpellReady("照明弹") then
        return false
    end
    return Cat2.WithCursorQuickcast(function()
        CastSpellByNameNoQueue("照明弹")
        return true
    end)
end

Cat2.RegisterCard(card)

