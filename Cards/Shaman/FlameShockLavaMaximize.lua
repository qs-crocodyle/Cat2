-- 火焰萨满使用：维持烈焰震击，并最大化施放熔岩爆裂。
local card = {
    id = "shaman_flame_shock_lava_maximize",
    name = "烈焰震击 熔岩爆裂 最大化",
    description = "维持烈焰震击，并在冷却完成时施放熔岩爆裂",
    details = "维持烈焰震击，并在冷却完成时施放熔岩爆裂。需要存在有效目标；目标火焰免疫时不会施放。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 26,
    category = "class",
    classes = {
        SHAMAN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_MeteorStorm",
        "Interface\\Icons\\Spell_Fire_FlameShock",
    },
    cooldown = { type = "spell", name = "熔岩爆裂" },
}

local flameShockDistance = 30
local lavaBurstDistance = 36

function card.RefreshRuntimeData()
    flameShockDistance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("烈焰震击", "等级 1"), "(%d+)码距离"))
    if not flameShockDistance then flameShockDistance = 20 end

    lavaBurstDistance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("熔岩爆裂", "等级 1"), "(%d+)码距离"))
    if not lavaBurstDistance then lavaBurstDistance = 36 end
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 目标火焰免疫时，不再尝试施放火焰伤害技能。
    if Cat2.IsFireImmune() then
        return false
    end

    -- 没有烈焰震击时优先补上。
    if not Cat2.GetFlameShockDot() then

        if Cat2.UnitXP then
            local range = UnitXP("distanceBetween", "player", "target")
            if range > flameShockDistance then
                return false
            end
        end

        if Cat2.SpellReadyOffset("烈焰震击",1.5) then
            Cat2.Cast("烈焰震击")
            return true
        end

        return false
    end

    -- 火震存在时，只要熔岩爆裂可用便立即施放。
    if Cat2.UnitXP then
        local range = UnitXP("distanceBetween", "player", "target")
        if range > lavaBurstDistance then
            return false
        end
    end

    if Cat2.SpellReady("熔岩爆裂") then
        Cat2.Cast("熔岩爆裂")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
