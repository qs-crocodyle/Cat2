-- 盾墙（自动姿态）技能卡片。
local card = {
    id = "warrior_shield_wall_auto_stance",
    name = "盾墙（自动姿态）",
    description = "生命低于|cff6bc7e0{triggerPercent}%|r时切换姿态并施放盾墙",
    details = "生命低于卡片设定值时，切换到防御姿态，并施放盾墙。会检查战斗状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 151,
    category = "class",
    classes = {
        WARRIOR = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_ShieldWall",
        "Interface\\Icons\\Ability_Warrior_DefensiveStance",
    },
    cooldown = {
        type = "spell",
        name = "盾墙",
    },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发生命",
            shortLabel = "血",
            unit = "%",
            default = 15,
            minimum = 1,
            maximum = 99,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 15

    if not player.inCombat then
        return false
    end


    if not Cat2.SpellReady("盾墙") then
        return false
    end

    -- 必须有盾牌
    if not Cat2.IsOffHandShield() then
        return false
    end


    if player.percentHealth < triggerPercent then

        if Cat2.GetShapeByName("防御姿态") then
            Cat2.Cast("盾墙")
        else
            Cat2.Cast("防御姿态")
        end

        return true
    end

    return false
end

Cat2.RegisterCard(card)
