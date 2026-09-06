-- 多重射击（仅多目标时）技能卡片。
local card = {
    id = "hunter_multi_shot_multiple_targets",
    name = "多重射击（仅多目标时）",
    description = "仅在目标多时施放多重射击，需要SuperWoW+UnitXP",
    details = "仅在目标多时，目标距离不低于8码时，施放多重射击。需要SuperWoW+UnitXP。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 51,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_UpgradeMoonGlaive",
    },
    cooldown = {
        type = "spell",
        name = "多重射击",
    },
}

local minimumDistance = 8
local maximumDistance = 35

function card.RefreshRuntimeData()
    local minimum, maximum = Cat2.Match(Cat2.GetSpellTooltip("多重射击", "等级 1"), "(%d+)%s*%-%s*(%d+)码距离")
    minimumDistance = tonumber(minimum) or 8
    maximumDistance = tonumber(maximum) or 35
end

function card.Execute(context)

    if not Cat2.UnitXP or not Cat2.SuperWoW then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and (targetDistance < minimumDistance or targetDistance > maximumDistance) then
            return false
        end
    end

    if not Cat2.SpellReady("多重射击") then
        return false
    end

    -- 40码敌人数量
	local list = {}
	local count = 0
	count,_,list,_ = Cat2.ScanNearbyEnemies(40)

    -- 40码敌人数量<2
	if count<2 then
		return false
	end

    count = 0

    -- 敌人群朝向
	for key, value in pairs(list) do

		-- 目标 1可以攻击 2未死亡 3排除小动物
		if UnitCanAttack("player", key) and not UnitIsDeadOrGhost(key) and UnitCreatureType(key) ~= "小动物" then
		-- 1正面朝向
        local behind = UnitXP("behind", key, "player")
		if behind==false then
			count = count + 1
		end
		end

	end

    -- 40码 正面朝向 敌人数量<2
	if count<2 then
		return false
	end

    Cat2.Cast("多重射击")
    return true
end

Cat2.RegisterCard(card)
