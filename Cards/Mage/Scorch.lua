-- 灼烧 技能卡片。
local card = {
    id = "mage_scorch",
    name = "灼烧",
    description = "施放灼烧，适合作为填充技能",
    details = "施放灼烧，适合作为填充技能。需要存在有效目标。",
    sort = 40,
    category = "class",
    classes = {
        MAGE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_SoulBurn",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    Cat2.CastWithoutNampower("灼烧")

    return false

end

Cat2.RegisterCard(card)