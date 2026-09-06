-- 特效治疗药膏卡片。
local card = {
    id = "item_major_healing_salve",
    name = "特效治疗药膏",
    description = "血量低于|cff6bc7e0{triggerPercent}%|r时使用特效治疗药膏",
    details = "战斗中血量低于卡片设定值时，使用特效治疗药膏。未单独设置时使用默认值30%。",
    sort = 90,
    category = "item",
    icons = {
        "Interface\\Icons\\major_healing_salve_1.blp",
    },
    cooldown = {
        type = "item",
        name = "特效治疗药膏",
    },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发血量",
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

    if player.inCombat and player.percentHealth<percent then
		Cat2.UseItemByName("特效治疗药膏")
    end
end

Cat2.RegisterCard(card)
