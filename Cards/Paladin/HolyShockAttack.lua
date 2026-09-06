-- 圣骑士神圣系：对当前敌方目标施放神圣震击。
local card = {
    id = "paladin_holy_shock_attack",
    name = "神圣震击（攻击）",
    description = "对当前敌方目标施放神圣震击",
    details = "对当前可攻击目标施放神圣震击。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 31,
    category = "class",
    classes = {
        PALADIN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_SearingLight",
    },
    cooldown = {
        type = "spell",
        name = "神圣震击",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists or not player.targetCanAttack then
        return false
    end

    if Cat2.SpellReady("神圣震击") and Cat2.TargetDistance("target",20) then
        Cat2.Cast("神圣震击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
