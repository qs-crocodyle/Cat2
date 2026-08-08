-- 吸取法力 技能卡片。
local card = {
    id = "warlock_drain_mana",
    name = "吸取法力",
    description = "施放吸取法力",
    details = "施放吸取法力。需要存在有效目标。",
    sort = 110,
    exclusiveGroup = "warlock_drain_spell",
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_SiphonMana",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    Cat2.CastWithoutNampower("吸取法力")
    return false -- 这里注意，需要与其他吸取不同，防止卡流程

end

Cat2.RegisterCard(card)
