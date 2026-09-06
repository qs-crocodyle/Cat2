-- 压制（主技能后）：复制“压制”，仅在已学主技能仍有足够冷却时间时使用。
local card = {
    id = "warrior_overpower_after_main_skill",
    name = "压制（主技能后）",
    description = "主技能冷却大于|cff6bc7e0{mainSkillCooldownThreshold}秒|r且怒气低于|cff6bc7e0{maximumRage}|r时施放压制",
    details = "致死打击或嗜血的剩余冷却时间大于卡片设定值时，才按原卡逻辑切换战斗姿态并施放压制。默认主技能冷却阈值2秒、最高怒气30。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 40.5,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_MeleeDamage",
        "Interface\\Icons\\Ability_Warrior_OffensiveStance",
    },
    cooldown = {
        type = "spell",
        name = "压制",
    },
    optionSchema = {
        {
            key = "maximumRage",
            type = "number",
            label = "最高怒气",
            shortLabel = "怒",
            default = 30,
            minimum = 1,
            maximum = 100,
        },
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
    },
}

function card.RefreshRuntimeData()
end

local function IsLearnedMainSkillCoolingLongEnough(spellName, cooldownThreshold)
    -- 嗜血与致死打击由不同天赋提供；只检查技能书中实际学会的主技能。
    if Cat2.GetSpellID(spellName) == 0 then
        return false
    end
    return Cat2.GetSpellIndependentCooldown(spellName) > cooldownThreshold
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local maximumRage = context:GetStepOption(step, "maximumRage") or 30
    local mainSkillCooldownThreshold = context:GetStepOption(step, "mainSkillCooldownThreshold") or 2

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    if not IsLearnedMainSkillCoolingLongEnough("致死打击", mainSkillCooldownThreshold) and
       not IsLearnedMainSkillCoolingLongEnough("嗜血", mainSkillCooldownThreshold) then
        return false
    end

    -- 压制触发，CD满足
    if Cat2.WarriorOverpower(3.2) and Cat2.SpellReadyOffset("压制",1.5) then

        if player.power>=5 and Cat2.GetShapeByName("战斗姿态") then

            Cat2.Cast("压制")
            return true

        end

        if player.power>=5 and player.power<maximumRage and not Cat2.GetShapeByName("战斗姿态") then
            Cat2.Cast("战斗姿态")
            return true
       end

        return true
    end

    return false
end

Cat2.RegisterCard(card)
