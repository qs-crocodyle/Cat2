-- 特效活力药水卡片之一。
local card = {
    id = "item_major_rejuvenation_potion_hp",
    name = "特效活力药水（血量）",
    description = "血量<30% 使用特效活力药水",
    details = "血量<30% 使用特效活力药水。会检查战斗状态。",
    sort = 70,
    category = "item",
    icons = {
        "Interface\\Icons\\INV_Potion_47",
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
		Cat2.UseItemByName("特效活力药水")
    end
end

Cat2.RegisterCard(card)
