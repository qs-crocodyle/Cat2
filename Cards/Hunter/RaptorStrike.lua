-- 猛禽一击 技能卡片。
local card = {
    id = "hunter_raptor_strike",
    name = "猛禽一击",
    description = "冷却好时，施放猛禽一击",
    details = "冷却好时，施放猛禽一击。需要存在有效目标。仅在技能可用时尝试执行。",
    sort = 10,
    category = "class",
    classes = {
        HUNTER = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_MeleeDamage",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    if Cat2.SpellReady("猛禽一击") then
        CastSpellByName("猛禽一击")
    end

    return false
end

Cat2.RegisterCard(card)
