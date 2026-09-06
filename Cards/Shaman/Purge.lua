-- 净化术：通过 Nampower 预先确认敌方目标存在可净化的魔法增益后再施放。
local card = {
    id = "shaman_purge",
    name = "净化术",
    description = "目标存在可净化的魔法增益时，施放净化术",
    details = "通过Nampower读取敌方目标的正面光环，发现可净化的魔法增益后才施放净化术。会检查施法状态、公共冷却、目标距离与视野；没有可净化魔法时不会产生施法动作。成功执行时会阻断本轮后续卡片。",
    sort = 72,
    category = "class",
    canStopSequence = true,
    classes = {
        SHAMAN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_Purge",
    },
    cooldown = { type = "spell", name = "净化术" },
}

local distance = 30

function card.RefreshRuntimeData()
end

-- Spell.dbc 的 Dispel 类型：1代表魔法。
local DISPEL_MAGIC = 1
local MAX_POSITIVE_AURAS = 32

-- Nampower 的 aura 字段包含48个原始光环槽位，前32个是正面增益。
-- 读取光环技能ID后查询 Spell.dbc，避免依赖服务器返回“没有可以驱散的效果”。
local function HasPurgeableMagicBuff(unit)
    if not Cat2.Nampower
    or type(GetUnitField) ~= "function"
    or type(GetSpellRecField) ~= "function" then
        return false
    end

    local auras = GetUnitField(unit, "aura")
    if type(auras) ~= "table" then
        return false
    end

    local index = 1
    while index <= MAX_POSITIVE_AURAS do
        local spellId = auras[index]
        if spellId and spellId > 0 then
            local dispelType = GetSpellRecField(spellId, "dispel")
            if dispelType == DISPEL_MAGIC then
                return true
            end
        end
        index = index + 1
    end

    return false
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists or not player.targetCanAttack then
        return false
    end
    if not HasPurgeableMagicBuff("target") then
        return false
    end
    if player.gcd > 0.2 or Cat2.GetIsCast() then
        return false
    end
    if not Cat2.SpellReady("净化术") then
        return false
    end

    if Cat2.UnitXP then
        local range = UnitXP("distanceBetween", "player", "target")
        if range and range > distance then
            return false
        end
        if not UnitXP("inSight", "player", "target") then
            return false
        end
    end

    Cat2.Cast("净化术")
    return false
end

Cat2.RegisterCard(card)
