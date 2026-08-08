-- 自动取消拯救：保留具体取消条件，供后续按实际战斗规则实现。
local card = {
    id = "common_auto_cancel_salvation",
    name = "自动取消拯救",
    description = "自动取消拯救Buff，适合坦克职业",
    details = "自动取消拯救Buff，适合坦克职业。",
    sort = 51,
    category = "common",
    icons = {
        "Interface\\Icons\\Spell_Holy_SealOfSalvation",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if player.buff["强效拯救祝福"] then
		Cat2.CancelBuffByName("强效拯救祝福")
    end

    if player.buff["拯救祝福"] then
		Cat2.CancelBuffByName("拯救祝福")
    end

end

Cat2.RegisterCard(card)
