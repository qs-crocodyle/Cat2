-- 神圣之火 技能卡片。
local card = {
    id = "priest_holy_fire",
    name = "神圣之火",
    description = "保持并施放神圣之火",
    details = "保持并施放神圣之火。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 50,
    category = "class",
    classes = {
        PRIEST = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_SearingLight",
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

	if not Cat2.GetHolyFireDot("target", 2.5) and (Cat2.GetCastHolyFireTimer()-GetTime())<0 then
		Cat2.CastWithoutNampower("神圣之火")
		return true
	end

    return false

end

Cat2.RegisterCard(card)
