-- 特效活力药水卡片之二；保留为独立卡片和独立流程位置。
local card = {
    id = "item_major_rejuvenation_potion_mp",
    name = "特效活力药水（蓝量）",
    description = "蓝量低于|cff6bc7e0{triggerPercent}%|r时使用特效活力药水",
    details = "战斗中蓝量低于卡片设定值时，使用特效活力药水。未单独设置时使用默认值30%。",
    sort = 80,
    category = "item",
    icons = {
        "Interface\\Icons\\INV_Potion_47",
    },
    cooldown = {
        type = "item",
        name = "特效活力药水",
    },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发蓝量",
            unit = "%",
            default = 30,
            minimum = 1,
            maximum = 99,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local percent = context:GetStepOption(step, "triggerPercent") or 30
    local player = Cat2.PlayerInformation.temporary

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end

    if player.inCombat and player.percentMana<percent then
		Cat2.UseItemByName("特效活力药水")
    end
end

Cat2.RegisterCard(card)
