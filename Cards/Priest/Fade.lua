-- 渐隐术 技能卡片。
local card = {
    id = "priest_fade",
    name = "渐隐术",
    description = "仇恨>|cff6bc7e0{threatPercent}%|r时，施放|cff6bc7e0{spellRank}级|r渐隐术",
    details = "自身仇恨高于卡片设定值时，按设定等级施放渐隐术。默认仇恨门槛为60%。无法取得有效仇恨数据时不执行。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 90,
    category = "class",
    canStopSequence = true,
    classes = {
        PRIEST = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Magic_LesserInvisibilty",
    },
    cooldown = {
        type = "spell",
        name = "渐隐术",
    },
    optionSchema = {
        {
            key = "spellRank",
            type = "number",
            label = "施法等级",
            shortLabel = "级",
            unit = "级",
            default = 6,
            minimum = 1,
            maximum = 6,
        },
        {
            key = "threatPercent",
            type = "number",
            label = "触发仇恨",
            shortLabel = "仇",
            unit = "%",
            default = 60,
            minimum = 1,
            maximum = 100,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local spellRank = context:GetStepOption(step, "spellRank") or 6
    local threatPercent = context:GetStepOption(step, "threatPercent") or 60

    local threat = Cat2.GetHatredFromTWT()
    if threat < 0 or threat <= threatPercent then
        return false
    end

    if Cat2.SpellReady("渐隐术") then
        Cat2.Cast("渐隐术(等级 " .. spellRank .. ")")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
