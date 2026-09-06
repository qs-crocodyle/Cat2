-- 旋风斩（群体时）技能卡片；执行逻辑暂与原旋风斩保持一致。
local card = {
    id = "warrior_whirlwind_group",
    name = "旋风斩（仅群体）",
    description = "群体怪>2、怒气达到|cff6bc7e0{rageThreshold}|r且冷却好时，施放旋风斩",
    details = "群体怪时，怒气达到卡片设定值且冷却好时施放旋风斩，单体不打。默认需要25怒气；满足装备减耗条件且未单独覆写参数时，自动降低为20怒气。需要存在有效目标。会检查目标距离。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 101,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Whirlwind",
    },
    optionSchema = {
        {
            key = "rageThreshold",
            type = "number",
            label = "怒气阈值",
            shortLabel = "怒",
            default = 25,
            minimum = 20,
            maximum = 100,
        },
    },
    cooldown = {
        type = "spell",
        name = "旋风斩",
    },
}

local powerWhirlwind = 25

function card.RefreshRuntimeData()

    powerWhirlwind = 25

    local count = 0
	if Cat2.CheckInventoryItemName(1,"兄弟会头盔") then count=count+1 end
	if Cat2.CheckInventoryItemName(2,"兄弟会项链") then count=count+1 end
	if Cat2.CheckInventoryItemName(3,"兄弟会肩甲") then count=count+1 end
	if Cat2.CheckInventoryItemName(5,"兄弟会胸甲") then count=count+1 end
	if Cat2.CheckInventoryItemName(7,"兄弟会护腿") then count=count+1 end
	if Cat2.CheckInventoryItemName(8,"兄弟会胫甲") then count=count+1 end
    if count >= 3 then
        powerWhirlwind = powerWhirlwind - 5
    end

end


function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    -- 未覆写参数时沿用技能实际消耗：基础 25，装备减耗后为 20。
    local rageThreshold = powerWhirlwind
    if type(step) == "table" and type(step.optionValues) == "table" and step.optionValues.rageThreshold ~= nil then
        rageThreshold = context:GetStepOption(step, "rageThreshold") or powerWhirlwind
    end

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    if not Cat2.GetShapeByName("狂暴姿态") then
        return false
    end

    local nearby = Cat2.ScanNearbyEnemies(8)
    if nearby>=3 then


    local requiredRage = powerWhirlwind
    if rageThreshold > requiredRage then
        requiredRage = rageThreshold
    end

    if player.power>=requiredRage and Cat2.SpellReadyOffset("旋风斩") then
        Cat2.Cast("旋风斩")
        return true
    end

    end

end

Cat2.RegisterCard(card)
