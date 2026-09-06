-- 圣盾术 技能卡片。
local card = {
    id = "paladin_divine_shield",
    name = "圣盾术",
    description = "生命<|cff6bc7e0{triggerPercent}%|r，危急时施放圣盾术",
    details = "生命低于卡片设定值时施放圣盾术。会检查战斗状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 130,
    category = "class",
    classes = {
        PALADIN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_DivineIntervention",
    },
    cooldown = {
        type = "spell",
        name = "圣盾术",
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

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end


    if not Cat2.SpellReady("圣盾术") then
        return false
    end

    -- 生命值
    if player.percentHealth < triggerPercent and not player.buff["自律"] then
        Cat2.Cast("圣盾术")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
