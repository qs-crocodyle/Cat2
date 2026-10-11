-- 猛击（乱舞，主技能后）：保留原普攻时间规则，优先已学会的主技能。
local card = {
    id = "warrior_slam_flurry_after_main_skills",
    name = "猛击（乱舞，主技能后）",
    description = "主技能在CD或怒气不足、乱舞生效、怒气达到|cff6bc7e0{rageThreshold}|r且普攻剩余|cff6bc7e0{minimumSwingTime}秒|r时施放",
    details = "已学会的致死打击、嗜血、旋风斩中，只要有技能独立冷却结束且怒气足够，就优先保留主技能；主技能在CD或怒气不足时允许尝试猛击。未学会的技能跳过，公共冷却不算。仅在乱舞生效、怒气达到设定值且普攻剩余时间大于设定值时施放猛击。默认15怒气、1.5秒。需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 112.1,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_DecisiveStrike_New",
        "Interface\\Icons\\Ability_GhoulFrenzy",
    },
    optionSchema = {
        {
            key = "minimumSwingTime",
            type = "number",
            label = "普攻剩余时间",
            shortLabel = "秒",
            unit = "秒",
            default = 1.5,
            minimum = 0.1,
            maximum = 5,
            integer = false,
        },
        {
            key = "rageThreshold",
            type = "number",
            label = "怒气阈值",
            shortLabel = "怒",
            default = 15,
            minimum = 15,
            maximum = 100,
        },
    },
}

local mainSkillRage = { ["致死打击"] = 30, ["嗜血"] = 30, ["旋风斩"] = 25 }

function card.RefreshRuntimeData()
    local whirlwindFallback = 25
    local setPieces = 0
    for _, item in ipairs({ { 1, "兄弟会头盔" }, { 2, "兄弟会项链" }, { 3, "兄弟会肩甲" },
        { 5, "兄弟会胸甲" }, { 7, "兄弟会护腿" }, { 8, "兄弟会胫甲" } }) do
        if Cat2.CheckInventoryItemName(item[1], item[2]) then setPieces = setPieces + 1 end
    end
    if setPieces >= 3 then whirlwindFallback = 20 end
    for spellName in pairs(mainSkillRage) do
        local tooltip = Cat2.GetSpellTooltip(spellName) or ""
        local cost = tonumber(Cat2.Match(tooltip, "(%d+)%s*点?怒气"))
        mainSkillRage[spellName] = cost or (spellName == "旋风斩" and whirlwindFallback or 30)
    end
    -- 沿用旋风斩卡的三件套减耗规则，即使技能提示未反映套装效果。
    if setPieces >= 3 then mainSkillRage["旋风斩"] = math.min(mainSkillRage["旋风斩"], 20) end
end

local function IsLearnedMainSkillReady(spellName, rage)
    return Cat2.GetSpellID(spellName) > 0 and rage >= mainSkillRage[spellName]
        and not Cat2.SpellOnCooldown(spellName)
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local minimumSwingTime = context:GetStepOption(step, "minimumSwingTime") or 1.5
    local rageThreshold = context:GetStepOption(step, "rageThreshold") or 15

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    if IsLearnedMainSkillReady("致死打击", player.power) or IsLearnedMainSkillReady("嗜血", player.power) or
        IsLearnedMainSkillReady("旋风斩", player.power) then
        return false
    end

    -- 优先读取可见乱舞；不可见时由战士专用事件维护的状态继续判断。
    if not Cat2.WarriorFlurry() then
        return false
    end

    if player.power>=rageThreshold and Cat2.GetMainHandLeft()>minimumSwingTime then
        Cat2.Cast("猛击")
        return true
    end

end

Cat2.RegisterCard(card)
