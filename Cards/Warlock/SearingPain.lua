-- 灼热之痛 技能卡片。
local card = {
    id = "warlock_searing_pain",
    name = "灼热之痛",
    description = "施放灼热之痛，适合做填充技能",
    details = "施放灼热之痛，适合做填充技能。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 30,
    category = "class",
    classes = {
        WARLOCK = 3,
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

    Cat2.CastWithoutNampower("灼热之痛")
    return true
end

Cat2.RegisterCard(card)