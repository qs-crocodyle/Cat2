-- 治疗石卡片。
local card = {
    id = "item_healthstone",
    name = "治疗石",
    description = "血量<30% 使用术士创造的治疗石",
    details = "血量<30% 使用术士创造的治疗石。会检查战斗状态。",
    sort = 30,
    category = "item",
    icons = {
        "Interface\\Icons\\INV_Stone_04",
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
		Cat2.UseItemByName("特效治疗石")
    end
end

Cat2.RegisterCard(card)
