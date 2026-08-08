-- 奥术飞弹 技能卡片。
local card = {
    id = "mage_arcane_missiles",
    name = "奥术飞弹",
    description = "施放奥术飞弹，适合做填充技能",
    details = "施放奥术飞弹，适合做填充技能。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 10,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_StarFall",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    Cat2.CastWithoutNampower("奥术飞弹")
    return true
end

Cat2.RegisterCard(card)
