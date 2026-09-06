-- 横扫攻击 技能卡片。
local card = {
    id = "warrior_sweeping_strikes",
    name = "横扫攻击",
    description = "周围|cff6bc7e0{scanRange}码|r多敌人，怒气<|cff6bc7e0{maximumRage}|r时，开启横扫",
    details = "周围设定距离内存在多个敌人，且怒气低于卡片设定值时开启横扫，敌人扫描需要SuperWoW。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 90,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_SliceDice",
        "Interface\\Icons\\Ability_Warrior_OffensiveStance",
    },
    cooldown = {
        type = "spell",
        name = "横扫攻击",
    },
    optionSchema = {
        {
            key = "scanRange",
            type = "number",
            label = "扫描距离",
            shortLabel = "距",
            unit = "码",
            default = 8,
            minimum = 1,
            maximum = 50,
        },
        {
            key = "maximumRage",
            type = "number",
            label = "怒气上限",
            shortLabel = "怒",
            default = 50,
            minimum = 21,
            maximum = 100,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local scanRange = context:GetStepOption(step, "scanRange") or 8
    local maximumRage = context:GetStepOption(step, "maximumRage") or 40

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    local nearby = Cat2.ScanNearbyEnemies(scanRange)

    if nearby > 1 and Cat2.SpellReadyOffset("横扫攻击",1.0) then

        if player.power>=20 and Cat2.GetShapeByName("战斗姿态") then

            Cat2.Cast("横扫攻击")
            return true

        end

        if player.power>=20 and player.power<maximumRage and not Cat2.GetShapeByName("战斗姿态") then
            Cat2.Cast("战斗姿态")
            return true
       end

        return true
    end


    return false
end

Cat2.RegisterCard(card)
