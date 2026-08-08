-- 魂能之速卡片。
local card = {
    id = "item_juju_flurry",
    name = "魂能之速",
    description = "冷却好后，使用魂能之速",
    details = "冷却好后，使用魂能之速。会检查战斗状态。",
    sort = 110,
    category = "item",
    icons = {
        "Interface\\Icons\\INV_Misc_MonsterScales_17",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end

    local boss = context and context.parameters and context.parameters.burstOnlyBoss
    if boss then
        if not Cat2.IsBossTarget() then
            return false
        end
    end

    if player.inCombat then

		if Cat2.GetItemByNameCD("魂能之速") then
            local target,guid = UnitExists("target")

            TargetUnit("player")
			Cat2.UseItemByName("魂能之速")

            if not target then
                ClearTarget()
            else
                TargetUnit(guid)
            end
		end

        -- 直接使用可能会有风险
        --Cat2.UseItemByName("魂能之速")
    end

end

Cat2.RegisterCard(card)
