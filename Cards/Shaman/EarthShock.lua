-- 大地震击 技能卡片。
local card = {
    id = "shaman_earth_shock",
    name = "大地震击",
    description = "冷却时，施放大地震击",
    details = "冷却时，施放大地震击。需要存在有效目标；目标自然免疫时不会施放。施放前可根据“大地震击切换图腾”或“震击切换图腾”被动卡切换对应圣物，专属被动优先；仅在冷却结束前1.5秒且当前处于公共冷却前半段时预先换装，技能真正就绪后才施放。切换装备本身不会阻断流程。本联动只作用于原始大地震击卡，不影响其分支；技能成功执行时会阻断本轮后续卡片。",
    sort = 30,
    category = "class",
    exclusiveGroup = "shaman_shock",
    classes = {
        SHAMAN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_EarthShock",
    },
    cooldown = { type = "spell", name = "大地震击" },
}

local distance = 20

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("大地震击", "等级 1"), "(%d+)码距离"))
    if not distance then distance = 20 end
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    -- 目标自然免疫时，不再尝试施放自然伤害技能。
    if Cat2.IsNatureImmune() then
        return false
    end

    -- 有unitxp模组，用于射程过滤
    if Cat2.UnitXP then
        local range = UnitXP("distanceBetween", "player", "target")
        if range and range>distance then
            return false
        end
    end

    local parameters = context and context.parameters
    local desiredTotem = parameters and parameters.shamanEarthShockTotem
    if type(desiredTotem)~="string" or desiredTotem=="" then
        desiredTotem = parameters and parameters.shamanShockTotem
    end

    if Cat2.SpellReadyOffset("大地震击",1.5) then
        Cat2.TryEquipShamanTotem(context, desiredTotem)
    end

    if Cat2.SpellReady("大地震击") then
        Cat2.Cast("大地震击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
