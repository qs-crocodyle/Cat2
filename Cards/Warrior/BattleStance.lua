-- 战斗姿态 技能卡片。
local card = {
    id = "warrior_battle_stance",
    name = "战斗姿态",
    description = "切换并保持战斗姿态",
    details = "切换并保持战斗姿态。成功执行时会阻断本轮后续卡片。",
    sort = 10,
    category = "class",
    exclusiveGroup = "warrior_stance",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_OffensiveStance",
    },
}

local ShapeshiftID = 0

function card.RefreshRuntimeData()
	for i = 1, 4 do
		local _, name, _, id = GetShapeshiftFormInfo(i)
        if name and name=="战斗姿态" then
            ShapeshiftID = i
            break
        end
	end
end

function card.Execute(context)

    if ShapeshiftID > 0 then

		if not Cat2.GetShape(ShapeshiftID) then
			CastShapeshiftForm(ShapeshiftID)
			return true
		end

    else

        if not Cat2.GetShapeByName("战斗姿态") then
            Cat2.Cast("战斗姿态")
            return true
        end

    end

    return false
end

Cat2.RegisterCard(card)
