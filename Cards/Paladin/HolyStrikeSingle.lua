-- 圣骑士惩戒系：只施放神圣打击。
local card = {
    id = "paladin_holy_strike_single",
    name = "神圣打击",
    description = "近战距离施放神圣打击",
    details = "近战距离施放神圣打击。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 70,
    category = "class",
    canStopSequence = true,
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\INV_Sword_01",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if Cat2.SpellReady("神圣打击") and Cat2.TargetDistance() then
        CastSpellByName("神圣打击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
