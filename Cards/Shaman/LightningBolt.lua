-- 闪电箭 技能卡片。
local card = {
    id = "shaman_lightning_bolt",
    name = "闪电箭",
    description = "施放|cff6bc7e0{spellRank}级|r闪电箭，未学习该等级时自动使用最高等级",
    details = "按卡片设定等级施放闪电箭；未学习指定等级时，直接施放闪电箭并由游戏选择最高已学习等级。适合作为填充技能。需要存在有效目标；目标自然免疫时不会施放。",
    sort = 10,
    category = "class",
    classes = {
        SHAMAN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_Lightning",
    },
    optionSchema = {
        {
            key = "spellRank",
            type = "number",
            label = "技能等级",
            shortLabel = "级",
            unit = "级",
            default = 10,
            minimum = 1,
            maximum = 10,
        },
    },
}

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("闪电箭","等级 1"), "(%d+)码距离"))
    if not distance then distance=30 end
end

function card.Execute(context, step)

    local spellRank = context:GetStepOption(step, "spellRank") or 10

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    -- 目标自然免疫时，不再尝试施放自然伤害技能。
    if Cat2.IsNatureImmune() then
        return false
    end

    -- 有unitxp模组，用于射程过滤
    if Cat2.UnitXP then
        local range = UnitXP("distanceBetween", "player", "target")
        if range>distance then
            return false
        end
    end

    local rankText = "等级 " .. spellRank
    if Cat2.GetSpellID("闪电箭", rankText)>0 then
        Cat2.Cast("闪电箭(" .. rankText .. ")")
    else
        -- 未学习指定等级时，不附加等级，让游戏自动选择最高已学习等级。
        Cat2.Cast("闪电箭")
    end

    return false
end

Cat2.RegisterCard(card)
