-- 圣骑士惩戒系：忏悔，仅对强敌使用。
local card = {
    id = "paladin_repentance_boss",
    name = "忏悔 仅强敌时",
    description = "仅对强敌目标施放忏悔",
    details = "仅对强敌目标施放忏悔。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 151,
    category = "class",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
    },
    cooldown = {
        type = "spell",
        name = "忏悔",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists or not Cat2.IsBossTarget() then
        return false
    end

    if Cat2.SpellReady("忏悔") and Cat2.TargetDistance("target",20) then
        Cat2.Cast("忏悔")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
