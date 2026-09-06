-- 斩杀（高怒）复制卡；执行逻辑与原斩杀卡保持一致。
local card = {
    id = "warrior_execute_high_rage",
    name = "斩杀（高怒）",
    description = "怒气达到|cff6bc7e0{minimumRage}|r且目标血量进入斩杀线时斩杀",
    details = "怒气达到设定值且目标血量进入斩杀线时施放斩杀。需要存在有效目标。会检查当前资源。启用“斩杀时中断读条”后，施放前会中断猛击读条。成功执行时会阻断本轮后续卡片。",
    sort = 97,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\INV_Sword_48",
    },
    optionSchema = {
        {
            key = "minimumRage",
            type = "number",
            label = "最低怒气",
            shortLabel = "怒",
            default = 50,
            minimum = 1,
            maximum = 100,
        },
    },
}

local powerExecute = 15

function card.RefreshRuntimeData()
    powerExecute = 15

    if Cat2.IsTalentLearned(2, 13) == 1 then
        powerExecute = powerExecute - 2
    elseif Cat2.IsTalentLearned(2, 13) == 2 then
        powerExecute = powerExecute - 5
    end
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local minimumRage = context:GetStepOption(step, "minimumRage") or 50

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    if Cat2.GetShapeByName("防御姿态") then
        return false
    end

    if player.power >= minimumRage and player.targetPercentHealth < 19.9 then
        if context.parameters.warriorInterruptCastForExecute then
            if Cat2.GetIsCast() then
                SpellStopCasting()
            end
        end
        Cat2.Cast("斩杀")
        return true
    end
end

Cat2.RegisterCard(card)
