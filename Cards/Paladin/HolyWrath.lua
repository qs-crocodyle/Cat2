-- 神圣愤怒 技能卡片。
local card = {
    id = "paladin_holy_wrath",
    name = "神圣愤怒",
    description = "在射程范围内，施放神圣愤怒",
    details = "在射程范围内，施放神圣愤怒。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 140,
    category = "class",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_Excorcism",
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


    if Cat2.SpellReady("神圣愤怒") and Cat2.TargetDistance("target",15) then
        CastSpellByName("神圣愤怒")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
