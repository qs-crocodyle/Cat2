-- 水之护盾（保持最高层）技能卡片；执行逻辑暂与原水之护盾保持一致。
local card = {
    id = "shaman_water_shield_highest_stacks",
    name = "水之护盾（保持最高层）",
    description = "施放水之护盾，同时只能持续一个盾",
    details = "施放水之护盾，同时只能持续一个盾。",
    sort = 53,
    exclusiveGroup = "shaman_shield",
    category = "class",
    classes = {
        SHAMAN = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Shaman_WaterShield",
    },
}

local WaterShieldLayer = 3

function card.RefreshRuntimeData()

    WaterShieldLayer = 3 + Cat2.IsTalentLearned(2,5)*2

	local count = 0
    -- T2 奶萨套
	if Cat2.CheckInventoryItemName(1,"无尽风暴角盔") then count=count+1 end
	if Cat2.CheckInventoryItemName(3,"无尽风暴肩胄") then count=count+1 end
	if Cat2.CheckInventoryItemName(5,"无尽风暴外衣") then count=count+1 end
	if Cat2.CheckInventoryItemName(6,"无尽风暴束腰") then count=count+1 end
	if Cat2.CheckInventoryItemName(7,"无尽风暴短裤") then count=count+1 end
	if Cat2.CheckInventoryItemName(8,"无尽风暴长靴") then count=count+1 end
	if Cat2.CheckInventoryItemName(9,"无尽风暴束腕") then count=count+1 end
	if Cat2.CheckInventoryItemName(10,"无尽风暴手套") then count=count+1 end
	if count >= 3 then
		WaterShieldLayer = WaterShieldLayer + 2
	end

end

function card.Execute(context)

    local AutoWaterShield = Cat2.CardRegistry.ById["shaman_auto_water_shield_mana"]

    if context:IsCardActive("shaman_auto_water_shield_mana")
        and AutoWaterShield
        and type(AutoWaterShield.GetCustomValue) == "function" then

        -- 自动水之护盾正在回蓝时，暂不执行补层逻辑。
        local value = AutoWaterShield.GetCustomValue(context)
        if value then
            return false
        end
    end

    local player = Cat2.PlayerInformation.temporary

    if not player.buff["水之护盾"] or Cat2.GetBuffApplications("Interface\\Icons\\Ability_Shaman_WaterShield")<WaterShieldLayer then
        Cat2.Cast("水之护盾")
        return
    end

    return false

end

Cat2.RegisterCard(card)
