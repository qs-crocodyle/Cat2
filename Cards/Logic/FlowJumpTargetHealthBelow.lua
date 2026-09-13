-- 目标当前血量低于设定值时，跳转到指定流程编号。
local card = {
    id = "logic_flow_jump_target_health_below",
    name = "根据目标血量 跳转流程",
    description = "目标血量<|cff6bc7e0{healthThreshold}|r时，跳转到第|cff6bc7e0{targetIndex}|r张卡片",
    details = "存在目标且目标当前血量严格低于设定值时跳转；血量使用实际数值，默认3000，不是百分比。血量等于或高于设定值、无目标时继续下一张卡片。跳转编号为1至60的整数，默认60，允许向前或向后跳转。目标编号不存在时提示并终止本轮；每轮最多执行60步。",
    sort = 59.8,
    category = "logic",
    behavior = "logic",
    canStopSequence = true,
    icons = {
        "Interface\\Icons\\INV_Misc_Wrench_01",
        "Interface\\Icons\\INV_Misc_Food_36",
    },
    optionSchema = {
        {
            key = "healthThreshold",
            type = "number",
            label = "血量阈值",
            shortLabel = "血量",
            default = 3000,
            minimum = 1,
            maximum = 1000000,
            integer = true,
        },
        {
            key = "targetIndex",
            type = "number",
            label = "跳转编号",
            shortLabel = "编号",
            default = 60,
            minimum = 1,
            maximum = 60,
            integer = true,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local player = context.playerInformation.temporary
    if not player.targetExists then
        return false
    end
    local healthThreshold = context:GetStepOption(step, "healthThreshold") or 3000
    if player.targetHealth < healthThreshold then
        return Cat2.JumpTo(context:GetStepOption(step, "targetIndex"))
    end
    return false
end

Cat2.RegisterCard(card)
