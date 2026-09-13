-- 压制 技能卡片。
local card = {
    id = "warrior_overpower",
    name = "压制",
    description = "怒气低于|cff6bc7e0{maximumRage}|r时切战斗姿态施放压制",
    details = "怒气低于卡片设定值时，切换战斗姿态并施放压制。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 40,
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
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local maximumRage = context:GetStepOption(step, "maximumRage") or 30

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    if Cat2.WarriorOverpower(3.2) and Cat2.SpellReadyOffset("压制",1.5) then
        if Cat2.GetShapeByName("战斗姿态") then
            Cat2.Cast("压制")
            return true
        end
    end

    -- 压制触发，CD满足
    if Cat2.WarriorOverpower(3.2) and Cat2.SpellReadyOffset("压制",1.5) and player.power>=5 and player.power<maximumRage then

        if Cat2.GetShapeByName("战斗姿态") then
            Cat2.Cast("压制")
        end

        if not Cat2.GetShapeByName("战斗姿态") then
            Cat2.Cast("战斗姿态")
        end

        return true
    end

    return false
end

Cat2.RegisterCard(card)
