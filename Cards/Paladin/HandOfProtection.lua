-- 圣骑士防护系：保护之手。
local card = {
    id = "paladin_hand_of_protection",
    name = "保护之手（自己）",
    description = "生命<|cff6bc7e0{triggerPercent}%|r，危急时对自己施放保护之手",
    details = "生命低于卡片设定值时对自己施放保护之手。会检查战斗状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 120,
    category = "class",
    classes = {
        PALADIN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_SealOfProtection",
    },
    cooldown = {
        type = "spell",
        name = "保护之手",
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


    if not Cat2.SpellReady("保护之手") then
        return false
    end

    -- 生命值
    if player.percentHealth < triggerPercent and not player.buff["自律"] then
        Cat2.CastSpellWithoutTarget("保护之手", "player")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
