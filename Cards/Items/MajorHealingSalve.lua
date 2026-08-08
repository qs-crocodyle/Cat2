-- 特效治疗药膏卡片。
local card = {
    id = "item_major_healing_salve",
    name = "特效治疗药膏",
    description = "血量<30% 使用特效治疗药膏",
    details = "血量<30% 使用特效治疗药膏。会检查战斗状态。",
    sort = 90,
    category = "item",
    icons = {
        "Interface\\Icons\\major_healing_salve_1.blp",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local percent = 30
    local player = Cat2.PlayerInformation.temporary

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end

    local p = context and context.parameters and context.parameters.recoveryPercent
    if p then
        percent = p
    end


    if player.inCombat and player.percentHealth<percent then
		Cat2.UseItemByName("特效治疗药膏")
    end
end

Cat2.RegisterCard(card)
