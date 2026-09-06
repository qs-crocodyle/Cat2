-- 寒冰箭 技能卡片。
local card = {
    id = "mage_frostbolt",
    name = "寒冰箭",
    description = "施放|cff6bc7e0{spellRank}级|r寒冰箭，适合作为填充技能",
    details = "按卡片设定等级施放寒冰箭；未学习指定等级时，直接施放寒冰箭并由游戏选择最高已学习等级。适合作为填充技能。需要存在有效目标；目标冰霜免疫时不会施放。",
    sort = 10,
    category = "class",
    classes = {
        MAGE = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_FrostBolt02",
    },
    optionSchema = {
        {
            key = "spellRank",
            type = "number",
            label = "技能等级",
            shortLabel = "级",
            unit = "级",
            default = 11,
            minimum = 1,
            maximum = 11,
        },
    },
}

local range = 30

function card.RefreshRuntimeData()
    local fallbackRange = 30 + (Cat2.IsTalentLearned(3,11)*3)
    range = tonumber(Cat2.Match(Cat2.GetSpellTooltip("寒冰箭", "等级 1"), "(%d+)码距离"))
    if not range then range = fallbackRange end
end

function card.Execute(context, step)

    local spellRank = context:GetStepOption(step, "spellRank") or 11

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 目标冰霜免疫时，不再尝试施放冰霜伤害技能。
    if Cat2.IsFrostImmune() then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > range then
            return false
        end
    end

    local rankText = "等级 " .. spellRank
    if Cat2.GetSpellID("寒冰箭", rankText)>0 then
        Cat2.Cast("寒冰箭(" .. rankText .. ")")
    else
        -- 未学习指定等级时，不附加等级，让游戏自动选择最高已学习等级。
        Cat2.Cast("寒冰箭")
    end

    return false

end

Cat2.RegisterCard(card)
