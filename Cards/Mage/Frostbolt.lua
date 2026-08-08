-- 寒冰箭 技能卡片。
local card = {
    id = "mage_frostbolt",
    name = "寒冰箭",
    description = "施放寒冰箭，适合作为填充技能",
    details = "施放寒冰箭，适合作为填充技能。需要存在有效目标。",
    sort = 10,
    category = "class",
    classes = {
        MAGE = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_FrostBolt02",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    Cat2.CastWithoutNampower("寒冰箭")

    return false

end

Cat2.RegisterCard(card)