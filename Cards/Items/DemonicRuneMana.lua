-- 恶魔符文（蓝量）卡片；保留足够生命值时用于恢复法力。
local card = {
    id = "item_demonic_rune_mana",
    name = "恶魔符文（蓝量）",
    description = "蓝量低于|cff6bc7e0{manaPercent}%|r且血量高于|cff6bc7e0{minimumHealth}|r时使用恶魔符文",
    details = "蓝量低于设定值且当前血量高于设定值时使用恶魔符文。未单独设置时，蓝量使用默认值30%，最低血量使用默认值1100。",
    sort = 45,
    category = "item",
    icons = {
        "Interface\\Icons\\INV_Misc_Rune_04",
    },
    cooldown = {
        type = "item",
        name = "恶魔符文",
    },
    optionSchema = {
        {
            key = "manaPercent",
            type = "number",
            label = "触发蓝量",
            shortLabel = "蓝",
            unit = "%",
            default = 30,
            minimum = 1,
            maximum = 99,
        },
        {
            key = "minimumHealth",
            type = "number",
            label = "最低血量",
            shortLabel = "血",
            unit = "",
            default = 1100,
            minimum = 1,
            maximum = 9999,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local percent = context:GetStepOption(step, "manaPercent") or 30
    local minimumHealth = context:GetStepOption(step, "minimumHealth") or 1100
    local player = Cat2.PlayerInformation.temporary

    if player.percentMana<percent and player.health>minimumHealth then
        Cat2.UseItemByName("恶魔符文")
    end

    return false
end

Cat2.RegisterCard(card)
