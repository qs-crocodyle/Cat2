-- 剑刃乱舞 技能卡片。
local card = {
    id = "rogue_blade_flurry",
    name = "剑刃乱舞",
    description = "周围多敌人时自动 [开/关] 剑刃乱舞，需SuperWoW",
    details = "周围多敌人时自动 [开/关] 剑刃乱舞，需SuperWoW。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 45,
    category = "class",
    classes = {
        ROGUE = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_PunishingBlow",
    },
}

function card.RefreshRuntimeData()
end


function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary
    local nearby = Cat2.ScanNearbyEnemies(8)

	if not player.buff["剑刃乱舞"] then

        if nearby > 1 and Cat2.SpellReady("剑刃乱舞") and player.gcd<0.2 then
		    Cat2.CastWithoutNampower("剑刃乱舞")
            return true
        end

	elseif player.buff["剑刃乱舞"] then

        if nearby <= 1 then
		    Cat2.CastWithoutNampower("剑刃乱舞")
        end

	end

    return false
end

Cat2.RegisterCard(card)
