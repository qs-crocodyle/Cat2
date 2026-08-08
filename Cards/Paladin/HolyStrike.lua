-- 神圣打击技能卡片。
local card = {
    id = "paladin_holy_strike",
    name = "神圣打击/十字军打击",
    description = "根据Buff时间施放，神圣打击先手",
    details = "根据Buff时间施放，神圣打击先手。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    -- 预留 60 给十字军打击，确保神圣打击排列在它前面。
    sort = 80,
    category = "class",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\INV_Sword_01",
        "Interface\\Icons\\Spell_Holy_CrusaderStrike",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end


    -- CD未好，未在近战范围
    if not Cat2.SpellReady("神圣打击") or not Cat2.TargetDistance() then
        return false
    end

	-- 主打神圣打击
	if GetTime()-Cat2.GetHolyStrikeDuration()>7 then
		CastSpellByName("神圣打击")
        return true
	elseif not Cat2.GetCrusaderStrike() or Cat2.GetFrenzyLayer()<3 then
		CastSpellByName("十字军打击")
        return true
	elseif Cat2.GetCrusaderStrike() and Cat2.GetFrenzyLayer()==3 and (GetTime()-Cat2.GetCrusaderStrikeDuration())>20 then
		CastSpellByName("十字军打击")
        return true
	else
		CastSpellByName("神圣打击")
        return true
	end

    return false
end

Cat2.RegisterCard(card)
