-- 无目标十字军打击技能卡片。
local card = {
    id = "paladin_crusader_strike_no_target",
    name = "十字军打击（无需目标）",
    description = "用于近战奶，无切换目标，施放十字军打击",
    details = "用于近战奶，无切换目标，施放十字军打击。仅在技能可用时尝试执行。",
    sort = 40.5,
    category = "class",
    classes = {
        PALADIN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_CrusaderStrike",
    },
    cooldown = {
        type = "spell",
        name = "十字军打击",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

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
