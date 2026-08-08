-- 自动取消法系 Buff：保留具体取消条件，供后续按实际战斗规则实现。
local card = {
    id = "common_auto_cancel_caster_buffs",
    name = "自动取消法系Buff",
    description = "自动取消法系增益效果，如：奥术智慧、精神祷言等",
    details = "自动取消法系增益效果，如：奥术智慧、精神祷言等。",
    sort = 52,
    category = "common",
    icons = {
        "Interface\\Icons\\Spell_Holy_DispelMagic",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

	Cat2.CancelBuffByName("奥术光辉")
	Cat2.CancelBuffByName("奥术智慧")
	Cat2.CancelBuffByName("精神祷言")
	Cat2.CancelBuffByName("神圣之灵")
	Cat2.CancelBuffByName("智慧祝福")
	Cat2.CancelBuffByName("强效智慧祝福")

end

Cat2.RegisterCard(card)
