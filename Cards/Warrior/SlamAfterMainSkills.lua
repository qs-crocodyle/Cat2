-- 猛击（主技能后）：主技能即将可用时为其保留时间与怒气。
local card = {
    id = "warrior_slam_after_main_skills",
    name = "猛击（主技能后）",
    description = "主技能冷却大于|cff6bc7e0{mainSkillCooldownThreshold}秒|r、怒气达到|cff6bc7e0{rageThreshold}|r且普攻剩余|cff6bc7e0{minimumSwingTime}秒|r时施放",
    details = "旋风斩、嗜血或致死打击任一技能冷却剩余不超过设定值时不施放。默认主技能冷却阈值2秒、15怒气、普攻剩余1.5秒。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    -- 紧随原“猛击”卡片。
    sort = 111,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_DecisiveStrike_New",
    },
    optionSchema = {
        {
            key = "mainSkillCooldownThreshold",
            type = "number",
            label = "主技能冷却阈值",
            shortLabel = "秒",
            unit = "秒",
            default = 2,
            minimum = 0,
            maximum = 10,
            integer = false,
        },
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

local function IsLearnedMainSkillReadySoon(spellName, cooldownThreshold)
    -- 嗜血与致死打击由不同天赋提供，不会同时存在；只检查技能书中实际学会的技能。
    if Cat2.GetSpellID(spellName) == 0 then
        return false
    end
    return Cat2.GetSpellIndependentCooldown(spellName) <= cooldownThreshold
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local mainSkillCooldownThreshold = context:GetStepOption(step, "mainSkillCooldownThreshold") or 2
    local minimumSwingTime = context:GetStepOption(step, "minimumSwingTime") or 1.5
    local rageThreshold = context:GetStepOption(step, "rageThreshold") or 15

    if not player.targetExists then
        return false
    end

    if IsLearnedMainSkillReadySoon("旋风斩", mainSkillCooldownThreshold) or
       IsLearnedMainSkillReadySoon("嗜血", mainSkillCooldownThreshold) or
       IsLearnedMainSkillReadySoon("致死打击", mainSkillCooldownThreshold) then
        return false
    end

    if player.power >= rageThreshold and Cat2.GetMainHandLeft() > minimumSwingTime then
        Cat2.Cast("猛击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
