-- 渐隐术 技能卡片。
local card = {
    id = "priest_fade",
    name = "渐隐术",
    description = "仇恨>|cff6bc7e0{threatPercent}%|r时，施放|cff6bc7e0{spellRank}级|r渐隐术；0为不检查仇恨，冷却好即用",
    details = "触发仇恨可设为0至100%，默认60%。设为0时无需读取或判定仇恨，每次流程执行到本卡且技能可用时立即尝试施放。大于0时，仅在取得有效仇恨数据且自身仇恨严格高于设定值时施放。按设定等级施放渐隐术，尝试施放后会阻断本轮后续卡片。",
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
            minimum = 0,
            maximum = 100,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local spellRank = context:GetStepOption(step, "spellRank") or 6
    local threatPercent = context:GetStepOption(step, "threatPercent") or 60

    if threatPercent > 0 then
        local threat = Cat2.GetHatredFromTWT()
        if threat < 0 or threat <= threatPercent then
            return false
        end
    end

    if Cat2.SpellReady("渐隐术") then
        Cat2.Cast("渐隐术(等级 " .. spellRank .. ")")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
