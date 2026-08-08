-- 胁迫 技能卡片。
local card = {
    id = "hunter_intimidation",
    name = "胁迫",
    description = "施放胁迫",
    details = "施放胁迫。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 3,
    category = "class",
    classes = {
        HUNTER = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Devour",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end

    if not UnitExists("pet") then
        return false
    end

    if Cat2.SpellReady("胁迫") then
        CastSpellByName("胁迫")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
