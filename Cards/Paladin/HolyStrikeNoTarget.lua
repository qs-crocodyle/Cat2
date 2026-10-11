-- 无目标神圣打击技能卡片。
local card = {
    id = "paladin_holy_strike_no_target",
    name = "神圣打击（无需目标）",
    description = "用于近战奶，无切换目标，施放|cff6bc7e0{spellRank}级|r神圣打击",
    details = "用于近战奶，无切换目标，按设定等级施放神圣打击。等级可设置为1–8，默认8级；未学习指定等级时使用最高已学习等级。仅在技能可用时尝试执行。",
    sort = 40,
    category = "class",
    classes = {
        PALADIN = 1,
    },
    icons = {
        "Interface\\Icons\\INV_Sword_01",
    },
    cooldown = {
        type = "spell",
        name = "神圣打击",
    },
    optionSchema = {
        { key = "spellRank", type = "number", label = "技能等级", shortLabel = "级", unit = "级",
            default = 8, minimum = 1, maximum = 8 },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local spellRank = context:GetStepOption(step, "spellRank") or 8
    local rankText = "等级 " .. spellRank
    local spellName = "神圣打击"
    if Cat2.GetSpellID(spellName, rankText) > 0 then
        spellName = spellName .. "(" .. rankText .. ")"
    end

    if Cat2.SpellReady("神圣打击") then
        local count,_,list = Cat2.ScanNearbyEnemies(6)
        if count>0 then

            -- 有近战敌人

            for key, value in pairs(list) do

                if Cat2.UnitXP then

			        -- 1正面朝向 2视野中
			        if not UnitXP("behind", key, "player") and UnitXP("inSight", "player", key) then

                    -- 校对key的可攻击性
			        if UnitCanAttack("player", key) and not UnitIsDeadOrGhost(key) then

                        -- 尝试神打
                        Cat2.CastSpellWithoutTarget(spellName, key)

                    end
                    end
                else
                    -- 尝试神打
                    Cat2.CastSpellWithoutTarget(spellName, key)
                end
            end
        end
    end

end

Cat2.RegisterCard(card)
