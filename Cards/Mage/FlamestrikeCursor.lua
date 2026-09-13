-- 在鼠标指向的地面位置直接施放烈焰风暴，不依赖当前目标或自身位置。
local card = {
    id = "mage_flamestrike_cursor",
    name = "烈焰风暴（指向）",
    description = "在鼠标指向位置直接施放烈焰风暴",
    details = "需要Nampower支持。在鼠标指向的地面位置施放烈焰风暴，无需选中目标或再次点击确认落点。仍需正常吟唱，并受法力、距离及冷却等限制。尝试施放后停止本轮后续卡片；当前环境不支持此功能时跳过。",
    sort = 55.3,
    category = "class",
    exclusiveGroup = "mage_flamestrike",
    classes = {
        MAGE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_SelfDestruct",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    if type(CastSpellByNameNoQueue) ~= "function" then
        return false
    end

    local cvar = "NP_QuickcastTargetingSpells"
    local readable, previous = pcall(GetCVar, cvar)
    if not readable or (previous ~= "0" and previous ~= "1") then
        return false
    end

    -- 由Nampower内部确认鼠标落点；禁止排队，确保在恢复设置前完成落点处理。
    local castOK, castError = pcall(function()
        SetCVar(cvar, "1")
        CastSpellByNameNoQueue(Cat2.GetAlternatingFlamestrikeName(context))
    end)
    -- 施法报错时也要恢复，避免影响其他地面法术。
    local restoreOK, restoreError = pcall(SetCVar, cvar, previous)
    if not restoreOK then
        error(restoreError, 0)
    end
    if not castOK then
        error(castError, 0)
    end
    return true
end

Cat2.RegisterCard(card)
