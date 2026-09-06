-- 狂暴回复：野性战斗系的低血量自保卡片。
local card = {
    id = "druid_frenzied_regeneration",
    name = "狂暴回复",
    description = "血量低于|cff6bc7e0{triggerPercent}%|r时施放狂暴回复",
    details = "自身血量低于卡片设定值时施放狂暴回复。默认触发血量为30%。仅在技能可用时尝试执行，成功施放后阻断本轮后续卡片。",
    sort = 339,
    category = "class",
    classes = {
        DRUID = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_BullRush",
    },
    cooldown = { type = "spell", name = "狂暴回复" },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发生命",
            shortLabel = "血",
            unit = "%",
            default = 30,
            minimum = 1,
            maximum = 99,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 30

    if player.percentHealth < triggerPercent and Cat2.SpellReady("狂暴回复") then
        Cat2.Cast("狂暴回复")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
