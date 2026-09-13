-- 破甲攻击（五层 仅强敌时）：在五层破甲卡的基础上增加强敌目标门禁。
local card = {
    id = "warrior_sunder_armor_five_boss",
    name = "破甲攻击（五层 仅强敌时）",
    description = "怒气达到|cff6bc7e0{rageThreshold}|r时仅对强敌保持五层破甲",
    details = "仅对强敌目标生效。怒气达到卡片设定值后，目标身上的破甲攻击不足五层时继续施放；达到五层后，在持续时间剩余不超过五秒时补一次以刷新持续时间，默认需要30怒气；需要SuperWoW模组。需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 22.5,
    category = "class",
    exclusiveGroup = "warrior_sunder_armor",
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
            default = 30,
            minimum = 5,
            maximum = 100,
        },
    },
}

local powerSunderArmor = 10
local REFRESH_REMAINING_SECONDS = 5

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
    local rageThreshold = context:GetStepOption(step, "rageThreshold") or 30

    -- 在原五层破甲门禁之前增加强敌判断，其余执行机制保持一致。
    if not player.targetExists or not Cat2.IsBossTarget() then
        return false
    end

    local applications = Cat2.GetDebuffApplications("Interface\\Icons\\Ability_Warrior_Sunder", "target")
    local remaining = Cat2.GetSunderArmorRemaining()
    local requiredRage = powerSunderArmor
    if rageThreshold > requiredRage then
        requiredRage = rageThreshold
    end

    if player.power>=requiredRage and (applications<5 or remaining<=REFRESH_REMAINING_SECONDS) then
        Cat2.Cast("破甲攻击")
        return true
    end
end

Cat2.RegisterCard(card)
