-- 拦截（自动姿态）技能卡片。
-- 复制拦截的原有逻辑：自动切换狂暴姿态后，在拦截距离内施放。
local card = {
    id = "warrior_intercept_auto_stance",
    name = "拦截（自动姿态）",
    description = "怒气<=|cff6bc7e0{maximumRage}怒气|r时，自动切姿态施放拦截",
    details = "当前怒气不少于10点且不高于卡片设定值时，自动切换至狂暴姿态，并在目标位于8-25码距离时施放拦截。需要存在有效目标。会检查当前怒气和目标距离。成功执行时会阻断本轮后续卡片。",
    sort = 81,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_Sprint",
        "Interface\\Icons\\Ability_Racial_Avatar",
    },
    cooldown = {
        type = "spell",
        name = "拦截",
    },
    optionSchema = {
        {
            key = "maximumRage",
            type = "number",
            label = "怒气上限",
            shortLabel = "怒",
            unit = "怒气",
            default = 100,
            minimum = 10,
            maximum = 100,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local maximumRage = context:GetStepOption(step, "maximumRage") or 100

    -- 拦截至少需要 10 点怒气，同时不能超过用户设定的怒气上限。
    if player.power < 10 or player.power > maximumRage then
        return false
    end

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    if not Cat2.SpellReady("拦截") then
        return false
    end

    -- 目标进入 8 码范围时不能拦截。
    if Cat2.TargetDistance("target", 8) then
        return false
    end

    if not Cat2.GetShapeByName("狂暴姿态") then
        Cat2.Cast("狂暴姿态")
        return true
    end

    Cat2.Cast("拦截")
    return true
end

Cat2.RegisterCard(card)
