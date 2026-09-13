-- 玩家处于战斗中时，跳转到指定流程编号。
local card = {
    id = "logic_flow_jump_in_combat",
    name = "战斗中 跳转流程",
    description = "玩家处于战斗中时，跳转到第|cff6bc7e0{targetIndex}|r张卡片",
    details = "按本轮玩家战斗状态判断：战斗中跳转到指定流程编号，非战斗中继续下一张卡片。编号为1至60的整数，默认60，允许向前或向后跳转。目标编号不存在时提示并终止本轮；每轮最多执行60步。不依赖目标是否存在或目标的战斗状态。",
    sort = 59.65,
    category = "logic",
    behavior = "logic",
    canStopSequence = true,
    icons = {
        "Interface\\Icons\\INV_Misc_Wrench_01",
        "Interface\\Icons\\Ability_DualWield",
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
    if context.playerInformation.temporary.inCombat ~= true then
        return false
    end
    return Cat2.JumpTo(context:GetStepOption(step, "targetIndex"))
end

Cat2.RegisterCard(card)
