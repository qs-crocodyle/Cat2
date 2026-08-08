-- 圣骑士惩戒系：只施放十字军打击。
local card = {
    id = "paladin_crusader_strike_single",
    name = "十字军打击",
    description = "近战距离施放十字军打击",
    details = "近战距离施放十字军打击。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 71,
    category = "class",
    canStopSequence = true,
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_CrusaderStrike",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if Cat2.SpellReady("十字军打击") and Cat2.TargetDistance() then
        CastSpellByName("十字军打击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
