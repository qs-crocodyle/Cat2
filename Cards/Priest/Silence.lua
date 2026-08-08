-- 沉默技能卡片。
local card = {
    id = "priest_silence",
    name = "沉默",
    description = "目标读条时，施放沉默，需SuperWoW模组",
    details = "目标读条时，施放沉默，需SuperWoW模组。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 100,
    category = "class",
    classes = {
        PRIEST = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_ImpPhaseShift",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 确认目标正在读条
    local cast,name = Cat2.TargetCast()
    if not cast then
        return false
    end

    if Cat2.SpellReady("沉默") then
        CastSpellByName("沉默")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
