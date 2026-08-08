-- 烈焰震击副本卡片，排序在熔岩爆裂之后。
local card = {
    id = "shaman_flame_shock_lava_followup",
    name = "熔岩爆裂 保持 烈焰震击",
    description = "通过烈焰震击，续杯火震DOT，需SuperWoW",
    details = "通过烈焰震击，续杯火震DOT，需SuperWoW。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 26,
    category = "class",
    classes = {
        SHAMAN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_FlameShock",
        "Interface\\Icons\\Spell_Fire_MeteorStorm",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end


    -- 要考虑弹道时间
    if Cat2.GetBeginLavaBurstCastTimer()-GetTime() > 0.0 then
        return false
    end


    -- 没有DOT
    if not Cat2.GetFlameShockDot() then

        -- 有unitxp模组，用于射程过滤
        if Cat2.UnitXP then
            local range = UnitXP("distanceBetween", "player", "target")
            if range>30 then
                return false
            end
        end

        if Cat2.SpellReadyOffset("烈焰震击",1.5) then
            CastSpellByName("烈焰震击")
            return true
        end

    else

        if not Cat2.GetFlameShockDot(5) then

            -- 有unitxp模组，用于射程过滤
            if Cat2.UnitXP then
                local range = UnitXP("distanceBetween", "player", "target")
                if range>36 then
                    return false
                end
            end

            Cat2.CastWithoutNampower("熔岩爆裂")
            return true
        end

    end

    return false

end

Cat2.RegisterCard(card)
