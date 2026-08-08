-- 狂暴强敌卡：仅面对强敌时使用低能量触发机制。
local card = {
    id = "druid_berserk_boss",
    name = "狂暴 仅强敌时",
    description = "仅对强敌在能量低于40时施放狂暴",
    details = "仅对强敌在能量低于40时施放狂暴。需要存在有效目标。会检查目标距离。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 423.2,
    category = "class",
    classes = {
        DRUID = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Druid_Berserk",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists or not Cat2.IsBossTarget() then
        return false
    end

    if player.power < 40 and Cat2.SpellReady("狂暴") and Cat2.TargetDistance() then
        CastSpellByName("狂暴")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
