-- 治疗祷言 技能卡片。
local card = {
    id = "priest_prayer_of_healing",
    name = "治疗祷言",
    description = "队伍3人掉血<80%，施放治疗祷言",
    details = "队伍3人掉血<80%，施放治疗祷言。会检查相关生命值。成功执行时会阻断本轮后续卡片。",
    sort = 60,
    category = "class",
    classes = {
        PRIEST = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_PrayerOfHealing02",
    },
}

function card.RefreshRuntimeData()
end


-- 治疗祷言 算式

local function PrayerHealthParty()

    local unit = "player"

    -- 检查是否在队伍
    local numPartyMembers = GetNumPartyMembers()
    if numPartyMembers and numPartyMembers>0 then

        local score = 0

        if Cat2.PlayerInformation.temporary.percentHealth < 80.0 then
            score = score + 1
        end

        -- 收集权重
        for i = 1, numPartyMembers do
            unit = "party" .. i
            if UnitExists(unit) and UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) and UnitHealthMax(unit)>0 then
                local percentHP =  UnitHealth(unit) / UnitHealthMax(unit) * 100
                if percentHP < 80.0 then
                    score = score + 1
                end
            end
        end

        -- 评分
        if score >= 3 then
            Cat2.CastSpellWithoutTarget("治疗祷言", "player", 1)
            return true
        end

    end

    return false
end

local function PrayerHealthRaid()

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
                    if percentHP < 80.0 then
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
        if temp >= 5 then

            targetParty = targetParty-1

            Cat2.CastSpellWithoutTarget("治疗祷言", "raid"..targetParty*5+1, 1)
            Cat2.CastSpellWithoutTarget("治疗祷言", "raid"..targetParty*5+2, 1)
            Cat2.CastSpellWithoutTarget("治疗祷言", "raid"..targetParty*5+3, 1)
            Cat2.CastSpellWithoutTarget("治疗祷言", "raid"..targetParty*5+4, 1)
            Cat2.CastSpellWithoutTarget("治疗祷言", "raid"..targetParty*5+5, 1)
            return true
        end

    end

    return false
end


function card.Execute(context)

    -- 被动卡：小队优先
    local partyFirst = context.parameters.HealingParty
    if partyFirst then
        if PrayerHealthParty() then
            return true
        end
    end

    -- 尝试祷言
    if PrayerHealthRaid() then
        return true
    end

    return false
end

Cat2.RegisterCard(card)
