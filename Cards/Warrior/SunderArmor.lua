-- 破甲攻击 技能卡片。
local card = {
    id = "warrior_sunder_armor",
    name = "破甲攻击",
    description = "无限施放破甲攻击，适合作为填充",
    details = "无限施放破甲攻击，适合作为填充。需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 20,
    category = "class",
    classes = {
        WARRIOR = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_Sunder",
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

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end


    -- 判断队列中是否存在盾猛
    -- 同队有盾猛时，优先把怒气留给盾猛
    if context:IsCardActive("warrior_shield_slam") then
        powerSunderArmor = powerSunderArmor + 20
    end

    if player.power>=powerSunderArmor then
        CastSpellByName("破甲攻击")
        return true
    end

end

Cat2.RegisterCard(card)