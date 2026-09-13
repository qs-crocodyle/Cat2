-- 目标免疫火焰伤害时，跳转到指定流程编号。
local card = {
    id = "logic_flow_jump_target_fire_immune",
    name = "目标免疫火焰 跳转流程",
    description = "目标免疫火焰伤害时，跳转到第|cff6bc7e0{targetIndex}|r张卡片",
    details = "存在目标且目标免疫火焰伤害时跳转到指定流程编号；无目标或条件不满足时继续下一张卡片。复用现有静态免疫名单及已捕获的目标免疫记录，不将普通抵抗或高抗性视为免疫。编号为1至60的整数，默认60，允许向前或向后跳转。目标编号不存在时提示并终止本轮；每轮最多执行60步。",
    sort = 62,
    category = "logic",
    behavior = "logic",
    canStopSequence = true,
    icons = {
        "Interface\\Icons\\INV_Misc_Wrench_01",
        "Interface\\Icons\\Spell_Fire_Fireball",
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
    if Cat2.IsDamageSchoolImmune("target", "fire") then
        return Cat2.JumpTo(context:GetStepOption(step, "targetIndex"))
    end
    return false
end

Cat2.RegisterCard(card)
