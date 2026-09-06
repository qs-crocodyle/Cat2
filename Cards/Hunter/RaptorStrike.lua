-- 猛禽一击 技能卡片。
local card = {
    id = "hunter_raptor_strike",
    name = "猛禽一击",
    description = "目标在8码内且冷却好时，施放猛禽一击",
    details = "目标在8码内且冷却好时，施放猛禽一击。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。",
    sort = 10,
    category = "class",
    classes = {
        HUNTER = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_MeleeDamage",
    },
    cooldown = {
        type = "spell",
        name = "猛禽一击",
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

    -- 目标必须位于8码范围内。
    if not Cat2.TargetDistance("target", 8) then
        return false
    end

    if Cat2.SpellReady("猛禽一击") then
        Cat2.Cast("猛禽一击")
    end

    return false
end

Cat2.RegisterCard(card)
