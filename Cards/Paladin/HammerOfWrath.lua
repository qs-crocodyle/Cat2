-- 愤怒之锤 技能卡片。
local card = {
    id = "paladin_hammer_of_wrath",
    name = "愤怒之锤",
    description = "满足技能条件时，施放愤怒之锤",
    details = "满足技能条件时，施放愤怒之锤。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 120,
    category = "class",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_ThunderClap",
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


    if Cat2.SpellReady("愤怒之锤") and Cat2.TargetDistance("target",30) and player.targetPercentHealth < 19.95 then
        CastSpellByName("愤怒之锤")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
