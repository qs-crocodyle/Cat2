-- 吸取生命 技能卡片。
local card = {
    id = "warlock_drain_life",
    name = "吸取生命",
    description = "施放吸取生命",
    details = "施放吸取生命。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 100,
    exclusiveGroup = "warlock_drain_spell",
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_LifeDrain02",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    Cat2.CastWithoutNampower("吸取生命")
    return true

end

Cat2.RegisterCard(card)
