-- 雷霆一击（攻击向）技能卡片。
local card = {
    id = "warrior_thunder_clap_offensive",
    name = "雷霆一击（攻击向）",
    description = "怒气达到|cff6bc7e0{rageThreshold}|r，周围至少|cff6bc7e0{minimumEnemies}|r个敌人时施放雷霆一击",
    details = "怒气达到卡片设定值，且周围8码内敌人数量达到设定值时施放雷霆一击。默认20怒气、2个敌人；实际怒气要求不会低于技能经天赋修正后的消耗。敌人扫描需要SuperWoW。需要存在有效目标。会检查目标距离。成功执行时会阻断本轮后续卡片。",
    sort = 80.1,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_ThunderClap",
    },
    optionSchema = {
        {
            key = "rageThreshold",
            type = "number",
            label = "怒气阈值",
            shortLabel = "怒",
            unit = "怒气",
            default = 20,
            minimum = 16,
            maximum = 100,
        },
        {
            key = "minimumEnemies",
            type = "number",
            label = "周围敌人数量",
            shortLabel = "敌",
            unit = "个",
            default = 2,
            minimum = 1,
            maximum = 20,
        },
    },
    cooldown = {
        type = "spell",
        name = "雷霆一击",
    },
}

local powerThunderClap = 20

function card.RefreshRuntimeData()
    if Cat2.IsTalentLearned(1, 6) == 3 then
        powerThunderClap = 16
    else
        powerThunderClap = 20 - Cat2.IsTalentLearned(1, 6)
    end
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local rageThreshold = context:GetStepOption(step, "rageThreshold") or 20
    local minimumEnemies = context:GetStepOption(step, "minimumEnemies") or 2

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    -- 近战距离。
    if not Cat2.TargetDistance("target", 7) then
        return false
    end

    -- 狂暴姿态下不执行。
    if Cat2.GetShapeByName("狂暴姿态") then
        return false
    end

    -- 雷霆一击以玩家为中心作用于周围8码内的敌人。
    local nearby = Cat2.ScanNearbyEnemies(8)
    if nearby < minimumEnemies then
        return false
    end

    local requiredRage = powerThunderClap
    if rageThreshold > requiredRage then
        requiredRage = rageThreshold
    end

    if player.power >= requiredRage then
        Cat2.Cast("雷霆一击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
