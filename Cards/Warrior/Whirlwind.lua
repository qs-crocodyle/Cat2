-- 旋风斩 技能卡片。
local card = {
    id = "warrior_whirlwind",
    name = "旋风斩",
    description = "冷却好时，施放旋风斩",
    details = "冷却好时，施放旋风斩。需要存在有效目标。会检查目标距离。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 100,
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

    -- 目标未在 8 码范围
    if not Cat2.TargetDistance("target",7) then
        return false
    end


    if player.power>=powerWhirlwind and Cat2.SpellReadyOffset("旋风斩") then
        CastSpellByName("旋风斩")
        return true
    end

end

Cat2.RegisterCard(card)