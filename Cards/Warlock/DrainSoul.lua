-- 吸取灵魂 技能卡片。
local card = {
    id = "warlock_drain_soul",
    name = "吸取灵魂",
    description = "施放吸取灵魂",
    details = "施放吸取灵魂。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 120,
    exclusiveGroup = "warlock_drain_spell",
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_Haunting",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    Cat2.CastWithoutNampower("吸取灵魂")
    return true

end

Cat2.RegisterCard(card)
