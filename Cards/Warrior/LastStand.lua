-- 破釜沉舟 技能卡片。
local card = {
    id = "warrior_last_stand",
    name = "破釜沉舟",
    description = "生命低于|cff6bc7e0{triggerPercent}%|r时施放破釜沉舟",
    details = "生命低于卡片设定值时施放破釜沉舟。会检查战斗状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 160,
    category = "class",
    classes = {
        WARRIOR = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_AshesToAshes",
    },
    cooldown = {
        type = "spell",
        name = "破釜沉舟",
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


    if not Cat2.SpellReady("破釜沉舟") then
        return false
    end

    if player.percentHealth < triggerPercent then
        Cat2.Cast("破釜沉舟")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
