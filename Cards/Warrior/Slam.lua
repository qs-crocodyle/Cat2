-- 猛击 技能卡片。
local card = {
    id = "warrior_slam",
    name = "猛击",
    -- 含参数占位的简介会在界面重绘时替换，不参与宏执行。
    description = "怒气达到|cff6bc7e0{rageThreshold}|r，普攻剩余|cff6bc7e0{minimumSwingTime}秒|r时施放猛击",
    details = "怒气达到设定值，并在普攻剩余时间大于设定值时施放猛击。默认15怒气、1.5秒。需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 110,
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
            default = 1.5,
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
    local minimumSwingTime = context:GetStepOption(step, "minimumSwingTime") or 1.5
    local rageThreshold = context:GetStepOption(step, "rageThreshold") or 15

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    if player.power>=rageThreshold and Cat2.GetMainHandLeft()>minimumSwingTime then
        Cat2.Cast("猛击")
        return true
    end

end

Cat2.RegisterCard(card)
