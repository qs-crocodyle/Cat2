-- 圣骑士防护系：自己生命危急时施放圣疗术。
local card = {
    id = "paladin_lay_on_hands_self",
    name = "圣疗术（自己）",
    description = "自己生命低于|cff6bc7e0{triggerPercent}%|r时，对自己施放圣疗术",
    details = "自己生命低于卡片设定值时，对自己施放圣疗术。会检查战斗状态。会检查相关生命值。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 140,
    category = "class",
    canStopSequence = true,
    classes = {
        PALADIN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_LayOnHands",
    },
    cooldown = {
        type = "spell",
        name = "圣疗术",
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

    if not player.inCombat or UnitIsDeadOrGhost("player") then
        return false
    end

    local health = UnitHealth("player")
    local maxHealth = UnitHealthMax("player")
    if health == 0 or maxHealth == 0 then
        return false
    end

    local percentHealth = health / maxHealth * 100
    if percentHealth >= triggerPercent then
        return false
    end

    if not player.buff["圣盾术"] and not player.buff["保护之手"] and Cat2.SpellReady("圣疗术") then
        Cat2.CastSpellWithoutTarget("圣疗术", "player")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
