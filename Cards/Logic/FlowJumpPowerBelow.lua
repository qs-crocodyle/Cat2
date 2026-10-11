-- 当前能量或怒气低于设定值时，跳转到指定流程编号。
local card = {
    id = "logic_flow_jump_power_below",
    name = "根据<能量/怒气 跳转流程",
    description = "能量/怒气<|cff6bc7e0{powerThreshold}|r时，跳转到第|cff6bc7e0{targetIndex}|r张卡片",
    details = "当前资源为能量或怒气，且实际点数严格低于设定值时跳转；默认50点，不是百分比。资源类型不符或等于、高于设定值时继续下一张卡片。跳转编号为1至60的整数，默认60，允许向前或向后跳转。目标编号不存在时提示并终止本轮；每轮最多执行60步。",
    sort = 59.82,
    category = "logic",
    behavior = "logic",
    canStopSequence = true,
    icons = {
        "Interface\\Icons\\INV_Misc_Wrench_01",
        "Interface\\Icons\\Spell_Holy_BlessingOfStamina",
    },
    optionSchema = {
        {
            key = "powerThreshold",
            type = "number",
            label = "能量/怒气阈值",
            shortLabel = "阈值",
            default = 50,
            minimum = 0,
            maximum = 1000,
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
    if player.powerType ~= 1 and player.powerType ~= 3 then
        return false
    end
    local powerThreshold = context:GetStepOption(step, "powerThreshold") or 50
    if player.power < powerThreshold then
        return Cat2.JumpTo(context:GetStepOption(step, "targetIndex"))
    end
    return false
end

Cat2.RegisterCard(card)
