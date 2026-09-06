-- 奥术射击 技能卡片。
local card = {
    id = "hunter_arcane_shot",
    name = "奥术射击",
    description = "目标距离不低于8码时，施放|cff6bc7e0{spellRank}级|r奥术射击",
    details = "目标距离不低于8码时，按卡片设定等级施放奥术射击；未学习指定等级时，直接施放奥术射击并由游戏选择最高已学习等级。需要存在有效目标；目标奥术免疫时不会施放。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 40,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_ImpalingBolt",
    },
    optionSchema = {
        {
            key = "spellRank",
            type = "number",
            label = "技能等级",
            shortLabel = "级",
            unit = "级",
            default = 8,
            minimum = 1,
            maximum = 8,
        },
    },
    cooldown = {
        type = "spell",
        name = "奥术射击",
    },
}

local minimumDistance = 8
local maximumDistance = 35

function card.RefreshRuntimeData()
    local minimum, maximum = Cat2.Match(Cat2.GetSpellTooltip("奥术射击", "等级 1"), "(%d+)%s*%-%s*(%d+)码距离")
    minimumDistance = tonumber(minimum) or 8
    maximumDistance = tonumber(maximum) or 35
end

function card.Execute(context, step)

    local spellRank = context:GetStepOption(step, "spellRank") or 8

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end

    -- 目标奥术免疫时，不再尝试施放奥术伤害技能。
    if Cat2.IsArcaneImmune() then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and (targetDistance < minimumDistance or targetDistance > maximumDistance) then
            return false
        end
    end

    if Cat2.SpellReady("奥术射击") then
        local rankText = "等级 " .. spellRank
        if Cat2.GetSpellID("奥术射击", rankText)>0 then
            Cat2.Cast("奥术射击(" .. rankText .. ")")
        else
            -- 未学习指定等级时，不附加等级，让游戏自动选择最高已学习等级。
            Cat2.Cast("奥术射击")
        end
        return true
    end

    return false
end

Cat2.RegisterCard(card)
