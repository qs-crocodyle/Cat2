-- 剔骨（四星）技能卡片。
local card = {
    id = "rogue_eviscerate_simple_4",
    name = "剔骨（四星）",
    description = "消耗4连击点施放剔骨",
    details = "消耗4连击点施放剔骨。需要存在有效目标，能量至少30。成功执行时会阻断本轮后续卡片。",
    sort = 24,
    category = "class",
    classes = {
        ROGUE = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_Eviscerate",
    },
}

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if player.power >= 30 and player.targetCombo == 4 then
        Cat2.Cast("剔骨")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
