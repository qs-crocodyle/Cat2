-- 盾牌格挡 技能卡片。
local card = {
    id = "warrior_shield_block",
    name = "盾牌格挡",
    description = "生命低于|cff6bc7e0{triggerPercent}%|r时，保持强化格挡并施放盾牌格挡",
    details = "生命低于卡片设定值时，保持强化格挡并施放盾牌格挡。默认触发血量为100%，盾牌猛击的格挡buff存在时不会施放，满血时不会施放。会检查目标距离、战斗状态和盾牌装备。仅在技能可用时尝试执行。",
    sort = 30,
    category = "class",
    classes = {
        WARRIOR = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Defend",
    },
    cooldown = {
        type = "spell",
        name = "盾牌格挡",
    },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发生命",
            shortLabel = "血",
            unit = "%",
            default = 100,
            minimum = 1,
            maximum = 100,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 100

    if not player.inCombat then
        return false
    end

    -- 仅在当前生命百分比严格低于设定值时允许施放。
    if player.percentHealth >= triggerPercent then
        return false
    end

    if not Cat2.SpellReady("盾牌格挡") then
        return false
    end

    -- 目标未在 8 码范围
    if not Cat2.TargetDistance("target",7) then
        return false
    end

    -- 必须有盾牌
    if not Cat2.IsOffHandShield() then
        return false
    end


    if not player.buff["强化盾牌猛击"] and not player.buff["盾牌格挡"] then
        Cat2.Cast("盾牌格挡")
    end

    return false
end

Cat2.RegisterCard(card)
