-- 畏缩技能卡片；猎豹形态下冷却完成且能量足够时施放。
local card = {
    id = "druid_cower",
    name = "畏缩",
    description = "冷却完成且能量足够时施放畏缩",
    details = "猎豹形态下，畏缩冷却完成且能量不少于20时施放。会检查当前资源和技能冷却。成功执行时会阻断本轮后续卡片。",
    sort = 423.3,
    category = "class",
    canStopSequence = true,
    classes = {
        DRUID = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Druid_Cower",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.buff["猎豹形态"] then
        return false
    end

    if player.power>=20 and Cat2.SpellReady("畏缩") then
        CastSpellByName("畏缩")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
