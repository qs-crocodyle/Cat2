-- 狂暴强敌卡：复制“狂暴（猫） 仅强敌时”，改为低血量触发机制。
local card = {
    id = "druid_berserk_bear_boss",
    name = "狂暴（熊） 仅强敌时",
    description = "仅强敌且血量低于|cff6bc7e0{triggerPercent}%|r时施放狂暴",
    details = "仅对强敌在血量低于卡片设定值时施放狂暴。需要存在有效目标。会检查目标距离。会检查当前血量。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 339.2,
    category = "class",
    classes = {
        DRUID = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Druid_Berserk",
    },
    cooldown = { type = "spell", name = "狂暴" },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发生命",
            shortLabel = "血",
            unit = "%",
            default = 30,
            minimum = 1,
            maximum = 99,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 30

    if not player.targetExists or not Cat2.IsBossTarget() then
        return false
    end

    if player.percentHealth < triggerPercent and Cat2.SpellReady("狂暴") and Cat2.TargetDistance() then
        Cat2.Cast("狂暴")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
