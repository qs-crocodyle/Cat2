-- 剑刃乱舞 技能卡片。
local card = {
    id = "rogue_blade_flurry",
    name = "剑刃乱舞",
    description = "周围|cff6bc7e0{scanRange}码|r多敌人时自动 [开/关] 剑刃乱舞，需SuperWoW",
    details = "周围设定距离内存在多个敌人时自动 [开/关] 剑刃乱舞，需SuperWoW。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 45,
    category = "class",
    classes = {
        ROGUE = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_PunishingBlow",
    },
    cooldown = {
        type = "spell",
        name = "剑刃乱舞",
    },
    optionSchema = {
        {
            key = "scanRange",
            type = "number",
            label = "扫描距离",
            shortLabel = "距",
            unit = "码",
            default = 8,
            minimum = 1,
            maximum = 50,
        },
    },
}

function card.RefreshRuntimeData()
end


function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local scanRange = context:GetStepOption(step, "scanRange") or 8
    local nearby = Cat2.ScanNearbyEnemies(scanRange)

	if not player.buff["剑刃乱舞"] then

        if nearby > 1 and Cat2.SpellReady("剑刃乱舞") and player.gcd<0.2 then
		    Cat2.Cast("剑刃乱舞")
            return true
        end

	elseif player.buff["剑刃乱舞"] then

        if nearby <= 1 then
		    Cat2.Cast("剑刃乱舞")
        end

	end

    return false
end

Cat2.RegisterCard(card)
