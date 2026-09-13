-- 圣骑士惩戒系：十字军打击。
local card = {
    id = "paladin_crusader_strike",
    name = "十字军打击/神圣打击",
    description = "根据Buff时间施放，十字军打击先手",
    details = "根据Buff时间施放，十字军打击先手。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 90,
    category = "class",
    exclusiveGroup = "paladin_holy_crusader_strike",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_CrusaderStrike",
        "Interface\\Icons\\INV_Sword_01",
    },
    cooldown = {
        type = "spell",
        name = "十字军打击",
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

	-- 主打十字军打击
	if not Cat2.GetCrusaderStrike() then
		Cat2.Cast("十字军打击")
        return true
	elseif Cat2.GetCrusaderStrike() and Cat2.GetFrenzyLayer()<2 then
		Cat2.Cast("十字军打击")
        return true
	else
		if GetTime()-Cat2.GetHolyStrikeDuration()>13 then
		    Cat2.Cast("神圣打击")
            return true
		else
		    Cat2.Cast("十字军打击")
            return true
		end
	end

    return false
end

Cat2.RegisterCard(card)
