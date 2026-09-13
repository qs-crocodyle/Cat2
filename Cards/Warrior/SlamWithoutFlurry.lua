-- 猛击（无乱舞时）：仅在乱舞未生效时执行原猛击逻辑。
local card = {
    id = "warrior_slam_without_flurry",
    name = "猛击（无乱舞时）",
    description = "无乱舞、怒气达到|cff6bc7e0{rageThreshold}|r且普攻剩余|cff6bc7e0{minimumSwingTime}秒|r时施放猛击",
    details = "仅在乱舞未生效、怒气达到设定值且普攻剩余时间大于设定值时施放猛击。默认15怒气、2.5秒。需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 110.5,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_DecisiveStrike_New",
    },
    optionSchema = {
        {
            key = "minimumSwingTime",
            type = "number",
            label = "普攻剩余时间",
            shortLabel = "秒",
            unit = "秒",
            default = 2.5,
            minimum = 0.1,
            maximum = 5,
            integer = false,
        },
        {
            key = "rageThreshold",
            type = "number",
            label = "怒气阈值",
            shortLabel = "怒",
            default = 15,
            minimum = 15,
            maximum = 100,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local minimumSwingTime = context:GetStepOption(step, "minimumSwingTime") or 2.5
    local rageThreshold = context:GetStepOption(step, "rageThreshold") or 15

    if not player.targetExists then
        return false
    end

    -- 与现有乱舞卡共用判断，包含可见 Buff 和事件维护的降级状态。
    if Cat2.WarriorFlurry() then
        return false
    end

    if player.power >= rageThreshold and Cat2.GetMainHandLeft() > minimumSwingTime then
        Cat2.Cast("猛击")
        return true
    end
end

Cat2.RegisterCard(card)
