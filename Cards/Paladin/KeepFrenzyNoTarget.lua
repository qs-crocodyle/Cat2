-- 保持狂热（无需目标）：狂热不存在或即将结束时，以无目标方式施放十字军打击。
local card = {
    id = "paladin_keep_frenzy_no_target",
    name = "保持 狂热（无需目标）",
    description = "狂热剩余不超过|cff6bc7e0{frenzyRemainingSeconds}秒|r时，无需切换目标施放十字军打击",
    details = "狂热不存在、已经结束或剩余时间不超过卡片设定值时，按无目标十字军打击的原有逻辑尝试施放。默认刷新窗口为10秒。仅在技能可用时尝试执行。",
    sort = 40.6,
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
    optionSchema = {
        {
            key = "frenzyRemainingSeconds",
            type = "number",
            label = "狂热剩余时间",
            shortLabel = "狂热",
            unit = "秒",
            default = 10,
            minimum = 0,
            maximum = 30,
            integer = false,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local frenzyRemainingSeconds = context:GetStepOption(step, "frenzyRemainingSeconds") or 10
    local frenzyAppliedAt = Cat2.GetCrusaderStrikeDuration() or 0
    if frenzyAppliedAt > 0 then
        local frenzyRemaining = 30 - (GetTime() - frenzyAppliedAt)
        if frenzyRemaining > frenzyRemainingSeconds then
            return false
        end
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
