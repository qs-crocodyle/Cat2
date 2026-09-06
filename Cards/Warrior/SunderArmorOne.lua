-- 破甲攻击（一破）技能卡片。
local card = {
    id = "warrior_sunder_armor_one",
    name = "破甲攻击（一破）",
    description = "怒气达到|cff6bc7e0{rageThreshold}|r时仅实施一次破甲攻击",
    details = "怒气达到卡片设定值时，对目标仅实施一次破甲攻击，默认需要10怒气；需要SuperWoW模组。需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 21,
    category = "class",
    classes = {
        WARRIOR = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_Sunder",
    },
    optionSchema = {
        {
            key = "rageThreshold",
            type = "number",
            label = "怒气阈值",
            shortLabel = "怒",
            default = 10,
            minimum = 5,
            maximum = 100,
        },
    },
}

local powerSunderArmor = 10

function card.RefreshRuntimeData()

    powerSunderArmor = 10

    local count = 0
	if Cat2.CheckInventoryItemName(1,"兄弟会头盔") then count=count+1 end
	if Cat2.CheckInventoryItemName(2,"兄弟会项链") then count=count+1 end
	if Cat2.CheckInventoryItemName(3,"兄弟会肩甲") then count=count+1 end
	if Cat2.CheckInventoryItemName(5,"兄弟会胸甲") then count=count+1 end
	if Cat2.CheckInventoryItemName(7,"兄弟会护腿") then count=count+1 end
	if Cat2.CheckInventoryItemName(8,"兄弟会胫甲") then count=count+1 end
    if count >= 3 then
        powerSunderArmor = powerSunderArmor - 5
    end

end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local rageThreshold = context:GetStepOption(step, "rageThreshold") or 10

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end


    local requiredRage = powerSunderArmor
    if rageThreshold > requiredRage then
        requiredRage = rageThreshold
    end

    if player.power>=requiredRage and not Cat2.GetSunderArmorOnce() then
        Cat2.Cast("破甲攻击")
        return true
    end

end

Cat2.RegisterCard(card)
