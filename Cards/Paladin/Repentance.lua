-- 圣骑士惩戒系：忏悔。
local card = {
    id = "paladin_repentance",
    name = "忏悔",
    description = "在射程范围内，施放忏悔",
    details = "在射程范围内，施放忏悔。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 150,
    category = "class",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
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


    if Cat2.SpellReady("忏悔") and Cat2.TargetDistance("target",20) then
        CastSpellByName("忏悔")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
