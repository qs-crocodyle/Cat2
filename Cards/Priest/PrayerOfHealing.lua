-- 治疗祷言 技能卡片。
local card = {
    id = "priest_prayer_of_healing",
    name = "治疗祷言",
    description = "队伍中血量<|cff6bc7e0{triggerPercent}%|r的人数>|cff6bc7e0{memberCountThreshold}人|r，施放|cff6bc7e0{spellRank}级|r治疗祷言",
    details = "队伍中血量低于卡片设定值的存活可见成员数量，严格大于人数参数时，按设定等级施放治疗祷言；未学习指定等级时，由游戏选择最高已学习等级。默认触发血量为80%，默认人数参数为2（即至少3人掉血）。成功执行时会阻断本轮后续卡片。",
    sort = 60,
    category = "class",
    classes = {
        PRIEST = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_PrayerOfHealing02",
    },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发血量",
            shortLabel = "血量",
            unit = "%",
            default = 80,
            minimum = 1,
            maximum = 99,
        },
        {
            key = "memberCountThreshold",
            type = "number",
            label = "人数阈值",
            shortLabel = "人数",
            unit = "人",
            default = 2,
            minimum = 0,
            maximum = 4,
        },
        {
            key = "spellRank",
            type = "number",
            label = "技能等级",
            shortLabel = "级",
            unit = "级",
            default = 5,
            minimum = 1,
            maximum = 5,
        },
    },
}

function card.RefreshRuntimeData()
end


-- 治疗祷言 算式

local function PrayerHealthParty(spellName, triggerPercent, memberCountThreshold)

    local unit = "player"

    -- 检查是否在队伍
    local numPartyMembers = GetNumPartyMembers()
    if numPartyMembers and numPartyMembers>0 then

        local score = 0

        if Cat2.PlayerInformation.temporary.percentHealth < triggerPercent then
            score = score + 1
        end

        -- 收集权重
        for i = 1, numPartyMembers do
            unit = "party" .. i
            if UnitExists(unit) and UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) and UnitHealthMax(unit)>0 then
                local percentHP =  UnitHealth(unit) / UnitHealthMax(unit) * 100
                if percentHP < triggerPercent then
                    score = score + 1
                end
            end
        end

        -- 评分
        if score > memberCountThreshold then
            Cat2.CastSpellWithoutTarget(spellName, "player", 1)
            return true
        end

    end

    return false
end

local function PrayerHealthRaid(spellName, triggerPercent, memberCountThreshold)

    -- 先检查是否在团队（经典旧世团队和队伍互斥）
    local numRaidMembers = GetNumRaidMembers()
    if numRaidMembers and numRaidMembers > 0 then
        local Party = 0
        local Score = {}

        -- 收集权重
        for i=1, 40, 5 do

            Party = Party + 1
            Score[Party] = 0

            for j=i, i+4 do
                local unit = "raid" .. j
                if UnitExists(unit) and UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) and UnitHealthMax(unit)>0 then
                    local percentHP =  UnitHealth(unit) / UnitHealthMax(unit) * 100
                    if percentHP < triggerPercent then
                        Score[Party] = Score[Party] + 1
                    end
                end
                --Score[Party] = Score[Party]+GetUnitScore(unit)
            end

        end

        -- 选择小队
        local targetParty = 0
        local temp = 0
        for i=1, 8 do
            if Score[i] > temp then
                temp = Score[i]
                targetParty = i
            end
        end

        -- 评分
        if temp > memberCountThreshold then

            targetParty = targetParty-1

            Cat2.CastSpellWithoutTarget(spellName, "raid"..targetParty*5+1, 1)
            Cat2.CastSpellWithoutTarget(spellName, "raid"..targetParty*5+2, 1)
            Cat2.CastSpellWithoutTarget(spellName, "raid"..targetParty*5+3, 1)
            Cat2.CastSpellWithoutTarget(spellName, "raid"..targetParty*5+4, 1)
            Cat2.CastSpellWithoutTarget(spellName, "raid"..targetParty*5+5, 1)
            return true
        end

    end

    return false
end


function card.Execute(context, step)

    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 80
    local memberCountThreshold = context:GetStepOption(step, "memberCountThreshold") or 2
    local spellRank = context:GetStepOption(step, "spellRank") or 5
    local rankText = "等级 " .. spellRank
    local spellName = "治疗祷言"
    if Cat2.GetSpellID("治疗祷言", rankText)>0 then
        spellName = "治疗祷言(" .. rankText .. ")"
    end

    -- 被动卡：小队优先
    local partyFirst = context.parameters.HealingParty
    if partyFirst then
        if PrayerHealthParty(spellName, triggerPercent, memberCountThreshold) then
            return true
        end
    end

    -- 尝试祷言
    if PrayerHealthRaid(spellName, triggerPercent, memberCountThreshold) then
        return true
    end

    return false
end

Cat2.RegisterCard(card)
