-- 目标为非强敌时，跳转到指定流程编号。
local card = {
    id = "logic_flow_jump_target_not_boss",
    name = "非强敌目标时 跳转流程",
    description = "非强敌目标时，跳转到第|cff6bc7e0{targetIndex}|r张卡片",
    details = "存在目标且目标为非强敌时跳转，沿用现有强敌判定；无目标或条件不满足时继续下一张卡片。跳转编号为1至60的整数，默认60，允许向前或向后跳转。目标编号不存在时提示并终止本轮；每轮最多执行60步。",
    sort = 59.9,
    category = "logic",
    behavior = "logic",
    canStopSequence = true,
    icons = {
        "Interface\\Icons\\INV_Misc_Wrench_01",
        "Interface\\Icons\\INV_Misc_Buckle_08",
    },
    optionSchema = {
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
    if player.targetIsBoss == false then
        return Cat2.JumpTo(context:GetStepOption(step, "targetIndex"))
    end
    return false
end

Cat2.RegisterCard(card)
