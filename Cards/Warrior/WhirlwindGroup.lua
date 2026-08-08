-- 旋风斩（群体时）技能卡片；执行逻辑暂与原旋风斩保持一致。
local card = {
    id = "warrior_whirlwind_group",
    name = "旋风斩（仅群体）",
    description = "群体怪>2时，冷却好时，施放旋风斩，单体不打",
    details = "群体怪时，冷却好时，施放旋风斩,单体不打。需要存在有效目标。会检查目标距离。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 101,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Whirlwind",
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


function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    if not Cat2.SetShape("狂暴姿态") then
        return false
    end

    local nearby = Cat2.ScanNearbyEnemies(8)
    if nearby>=3 then


    if player.power>=powerWhirlwind and Cat2.SpellReadyOffset("旋风斩") then
        CastSpellByName("旋风斩")
        return true
    end

    end

end

Cat2.RegisterCard(card)
