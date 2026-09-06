-- 神圣之盾（被目标注视）技能卡片；执行逻辑与原神圣之盾保持一致。
local card = {
    id = "paladin_holy_shield_target_watching",
    name = "神圣之盾（被目标注视）",
    description = "冷却好时，并且目标看着你，施放神圣之盾",
    details = "冷却好时，并且目标看着你，施放神圣之盾。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 91,
    category = "class",
    classes = {
        PALADIN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_BlessingOfProtection",
    },
    cooldown = {
        type = "spell",
        name = "神圣之盾",
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

    -- 必须有盾牌
    if not Cat2.IsOffHandShield() then
        return false
    end

    -- 目标的目标是不是自己
    if not UnitExists("targettarget") or not UnitIsUnit("targettarget", "player") then
        return false
    end

    if not Cat2.SpellReady("神圣之盾") then
        return false
    end

    Cat2.Cast("神圣之盾")
    return true
end

Cat2.RegisterCard(card)
