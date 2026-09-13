-- 自动锁敌（远程）：调用公共锁敌逻辑，保留独立卡片标识与运行节流状态。
local card = {
    id = "common_auto_target_ranged",
    name = "自动锁敌（远程）",
    description = "选择|cff6bc7e0{maximumDistance}码|r内最近的正面敌对目标。",
    details = "选择设定距离内最近的敌对目标，并检查正面与视野；默认最大距离为41码。死亡目标会被放弃；其他情况下没有合格替代目标时保留当前目标。切换或清除目标后会立即刷新角色数据并继续本轮流程。无SuperWoW时降级为原生最近目标：不保证距离、正面、视野及小动物过滤。",
    exclusiveGroup = "common_auto_target",
    sort = 21,
    category = "common",
    icons = {
        "Interface\\Icons\\Ability_Hunter_SniperShot",
    },
    optionSchema = {
        {
            key = "maximumDistance",
            type = "number",
            label = "锁敌距离",
            unit = "码",
            default = 36,
            minimum = 1,
            maximum = 100,
        },
    },
}

local EXECUTION_INTERVAL = 0.1
local nextExecutionTime = 0

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local currentTime = GetTime()
    if currentTime < nextExecutionTime then
        return false
    end
    nextExecutionTime = currentTime + EXECUTION_INTERVAL

    local maximumDistance = context:GetStepOption(step, "maximumDistance") or 41
    return Cat2.ExecuteAutoTarget(context, maximumDistance)
end

Cat2.RegisterCard(card)
