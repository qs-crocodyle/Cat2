-- 火球术 技能卡片。
local card = {
    id = "mage_fireball",
    name = "火球术",
    description = "施放火球术，适合作为填充技能",
    details = "施放火球术，适合作为填充技能。需要存在有效目标。",
    sort = 10,
    category = "class",
    classes = {
        MAGE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_FlameBolt",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    Cat2.CastWithoutNampower("火球术")

    return false

end

Cat2.RegisterCard(card)