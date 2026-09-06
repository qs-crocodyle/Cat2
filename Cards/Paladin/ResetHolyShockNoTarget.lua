-- 重置神圣震击（无需目标）：神圣震击处于独立冷却时，以无目标方式施放十字军打击。
local card = {
    id = "paladin_reset_holy_shock_no_target",
    name = "重置 神圣震击（无需目标）",
    description = "神圣震击冷却时，无需切换目标施放十字军打击",
    details = "仅当已学习的神圣震击处于自身技能冷却时，按无目标十字军打击的原有逻辑尝试施放；公共冷却不会被误判为神圣震击冷却。仅在十字军打击可用时尝试执行。",
    sort = 40.55,
    category = "class",
    classes = {
        PALADIN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_CrusaderStrike",
        "Interface\\Icons\\Spell_Holy_SearingLight",
    },
    cooldown = {
        type = "spell",
        name = "十字军打击",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not Cat2.SpellOnCooldown("神圣震击") then
        return false
    end

    if Cat2.SpellReady("十字军打击") then
        local count,_,list = Cat2.ScanNearbyEnemies(6)
        if count>0 then

            -- 有近战敌人

            for key, value in pairs(list) do

                if Cat2.UnitXP then

			        -- 1正面朝向 2视野中
			        if not UnitXP("behind", key, "player") and UnitXP("inSight", "player", key) then

                    -- 校对key的可攻击性
			        if UnitCanAttack("player", key) and not UnitIsDeadOrGhost(key) then

                        -- 尝试十字军打击
                        Cat2.CastSpellWithoutTarget("十字军打击", key)

                    end
                    end
                else
                    -- 尝试十字军打击
                    Cat2.CastSpellWithoutTarget("十字军打击", key)
                end
            end
        end
    end

end

Cat2.RegisterCard(card)
