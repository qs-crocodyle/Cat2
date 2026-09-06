-- 闪电链 技能卡片。
local card = {
    id = "shaman_chain_lightning",
    name = "闪电链",
    description = "冷却时，施放|cff6bc7e0{spellRank}级|r闪电链，未学习时自动最高等级",
    details = "冷却结束后，按卡片设定等级施放闪电链；未学习指定等级时，直接施放闪电链并由游戏选择最高已学习等级。需要存在有效目标；目标自然免疫时不会施放。成功执行时会阻断本轮后续卡片。",
    sort = 20,
    category = "class",
    classes = {
        SHAMAN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_ChainLightning",
    },
    cooldown = { type = "spell", name = "闪电链" },
    optionSchema = {
        {
            key = "spellRank",
            type = "number",
            label = "技能等级",
            shortLabel = "级",
            unit = "级",
            default = 4,
            minimum = 1,
            maximum = 4,
        },
    },
}

local distance = 30

function card.RefreshRuntimeData()

    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("闪电链","等级 1"), "(%d+)码距离"))
    if not distance then distance=30 end

end

function card.Execute(context, step)

    local spellRank = context:GetStepOption(step, "spellRank") or 4

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

    if Cat2.SpellReadyOffset("闪电链",1.5) then
        local rankText = "等级 " .. spellRank
        if Cat2.GetSpellID("闪电链", rankText)>0 then
            Cat2.Cast("闪电链(" .. rankText .. ")")
        else
            -- 未学习指定等级时，不附加等级，让游戏自动选择最高已学习等级。
            Cat2.Cast("闪电链")
        end
        return true
    end

end

Cat2.RegisterCard(card)
