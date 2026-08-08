-- 精神鞭笞 技能卡片。
local card = {
    id = "priest_mind_flay",
    name = "精神鞭笞",
    description = "对目标施放精神鞭笞",
    details = "对目标施放精神鞭笞。需要存在有效目标。",
    sort = 30,
    category = "class",
    classes = {
        PRIEST = 3,
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

    CastSpellByName("精神鞭笞")

    return false
end

Cat2.RegisterCard(card)