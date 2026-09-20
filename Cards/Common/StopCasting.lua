-- 中断玩家当前施法或引导，继续执行后续卡片。
local card = {
    id = "common_stop_casting",
    name = "中断自己施法",
    description = "中断自己当前的施法或引导",
    details = "中断自己当前的施法读条或引导，无需目标。未在施法或引导时无效果。执行后继续后续卡片。",
    sort = 50.6,
    category = "common",
    icons = {
        "Interface\\Icons\\Ability_Mage_IncantersAbsorbtion",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    SpellStopCasting()
    return false
end

Cat2.RegisterCard(card)
