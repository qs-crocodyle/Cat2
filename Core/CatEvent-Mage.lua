local _, playerClass = UnitClass("player")
if playerClass ~= "MAGE" then
    return  -- 终止文件执行
end

local frame = CreateFrame("Frame")

-- Nampower 结构化事件在不支持它们的客户端中可能不是合法事件，使用保护注册安全降级。
local function RegisterOptionalEvent(eventName)
    Cat2.RegisterOptionalEvent(frame, eventName)
end

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
frame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
frame:RegisterEvent("SPELLCAST_START")

frame:RegisterEvent("SPELLCAST_CHANNEL_START")
frame:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
frame:RegisterEvent("SPELLCAST_CHANNEL_STOP")
frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
frame:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")


-- SuperWow专有事件
RegisterOptionalEvent("UNIT_CASTEVENT")
RegisterOptionalEvent("SPELL_GO_SELF")
RegisterOptionalEvent("RAW_COMBATLOG")

-- Nampower专有事件
RegisterOptionalEvent("BUFF_REMOVED_SELF")
RegisterOptionalEvent("SPELL_DAMAGE_EVENT_SELF")
RegisterOptionalEvent("SPELL_DAMAGE_EVENT_OTHER")
RegisterOptionalEvent("AURA_CAST_ON_OTHER")
RegisterOptionalEvent("DEBUFF_REMOVED_OTHER")


-- 等待技能反馈的等待时间
local BLEENCHECKDELAY = 0.2

-- 奥术涌动 状态
local MageArcaneSurgeNoSW = 0
local MageArcaneSurge = 0
local MageArcaneSurgeGUID = 0

-- 法师当前引导状态。旧接口仍沿用“奥术飞弹”命名，供现有卡片兼容读取。
local MageArcaneMissilesDuration = 0
local MageArcaneMissilesTimer = 0
local MageChanneledSpellID = 0
local MageChanneledSpellName = nil
local PendingMageChanneledSpellName = nil
local PendingMageChanneledSpellTimer = 0

-- “断条补溃裂”只允许中断奥术飞弹；其他引导与无法识别名称的引导继续受保护。
local MageInterruptibleChannelNames = {
    ["奥术飞弹"] = true,
}
local MageSpellNameCache = {}

-- 原生 1.12 的引导开始事件不携带技能名称，因此在 Cat2 发起引导前暂存白名单名称。
function Cat2.RecordMageChannelCast(spellName)
    if MageInterruptibleChannelNames[spellName] then
        PendingMageChanneledSpellName = spellName
        PendingMageChanneledSpellTimer = GetTime()
    else
        PendingMageChanneledSpellName = nil
        PendingMageChanneledSpellTimer = 0
    end
end

local function GetMageSpellNameByID(spellID)
    if not spellID or spellID == 0 then
        return nil
    end

    local spellName = MageSpellNameCache[spellID]
    if not spellName and type(GetSpellNameAndRankForId) == "function" then
        spellName = GetSpellNameAndRankForId(spellID)
    end
    if not spellName and type(SpellInfo) == "function" then
        spellName = SpellInfo(spellID)
    end
    if spellName then
        MageSpellNameCache[spellID] = spellName
    end

    return spellName
end

-- Nampower 4+ 可直接提供当前引导技能 ID，作为无 SuperWoW 时的首选来源。
-- 三种烈焰风暴落点卡共用状态，只由完成施法事件推进。
local FlamestrikeAlternationEnabled = false
local FlamestrikeLastSuccessTime = nil
local FlamestrikeLastSuccessRank = nil
local FlamestrikeRequestedRank = nil

function Cat2.GetAlternatingFlamestrikeName(context)
    local enabled = context and context.parameters
        and context.parameters.mageFlamestrikeAlternateRanks
    if not enabled then
        FlamestrikeAlternationEnabled = false
        FlamestrikeLastSuccessTime = nil
        FlamestrikeLastSuccessRank = nil
        FlamestrikeRequestedRank = nil
        return "烈焰风暴"
    end
    FlamestrikeAlternationEnabled = true

    -- 从技能书选出真正学会的两个最高等级，兼容缺失中间等级的情况。
    local highest, second = 0, 0
    local index = 1
    while true do
        local name, rankText = GetSpellName(index, "spell")
        if not name then break end
        if name == "烈焰风暴" then
            local _, _, number = string.find(rankText or "", "(%d+)")
            local rank = tonumber(number) or 1
            if rank > highest then
                second, highest = highest, rank
            elseif rank < highest and rank > second then
                second = rank
            end
        end
        index = index + 1
    end
    local rank = highest
    if FlamestrikeLastSuccessTime and GetTime() - FlamestrikeLastSuccessTime < 10
        and FlamestrikeLastSuccessRank == highest and second > 0 then
        rank = second
    end
    FlamestrikeRequestedRank = rank
    return Cat2.GetRankedSpellName("烈焰风暴", rank) or "烈焰风暴"
end

local function RecordFlamestrikeSuccess(spellID)
    if not FlamestrikeAlternationEnabled then return end
    local name, rankText
    if type(GetSpellNameAndRankForId) == "function" then
        name, rankText = GetSpellNameAndRankForId(spellID)
    end
    if not name and type(SpellInfo) == "function" then
        name, rankText = SpellInfo(spellID)
    end
    if name ~= "烈焰风暴" then return end
    local _, _, number = string.find(tostring(rankText or ""), "(%d+)")
    FlamestrikeLastSuccessRank = tonumber(number) or FlamestrikeRequestedRank
    FlamestrikeLastSuccessTime = GetTime()
end

local function GetNampowerMageChanneledSpellName()
    if type(GetCastInfo) ~= "function" then
        return nil
    end

    local castInfo = GetCastInfo()
    if type(castInfo) ~= "table" or castInfo.castType ~= 3 then
        return nil
    end

    return GetMageSpellNameByID(castInfo.spellId)
end

-- 没有 SuperWoW/Nampower 名称时读取原生施法条；只接受奥术飞弹，避免误认其他引导。
local function GetNativeMageChanneledSpellName()
    local spellName

    if CastingBarText and type(CastingBarText.GetText) == "function" then
        spellName = CastingBarText:GetText()
        if spellName and MageInterruptibleChannelNames[spellName] then
            return spellName
        end
    end

    if CastingBarFrameText and type(CastingBarFrameText.GetText) == "function" then
        spellName = CastingBarFrameText:GetText()
        if spellName and MageInterruptibleChannelNames[spellName] then
            return spellName
        end
    end

    return nil
end

-- 冰柱 持续时间
local MageIcicleDuration = 0
local MageIcicleTimer = 0

-- 火焰易伤层数
local FireVulnerabilityLayer = {}

-- 灼烧
local ScorchCheck = {}
local ScorchDelayTime = {}

-- 火焰冲击
local FireBlastCheck = {}
local FireBlastDelayTime = {}

-- 炎爆术弹道延迟
local MageCastPyroblastTimer = 0
local MagePyromaniac = 0

-- 气定神闲
local MageCalmTimer = 0

-- 当前点燃每跳伤害。单次暴击先计算40%的点燃总贡献，再平分为两跳；
-- 滚动点燃若已经跳过一次，则把旧点燃剩余的一跳与新贡献合并后重新平分。
-- 实际跳伤到来后用战斗日志中的真实数值校准。
local IgniteDamage = {}
local IgniteCheck = {}
local IgniteLastTickCheck = {}
local IgniteOwnership = {}

local IGNITE_OWNERSHIP_PENDING = "pending"
local IGNITE_OWNERSHIP_MINE = "mine"
local IGNITE_OWNERSHIP_OTHER = "other"
local IGNITE_SPELL_ID = 12654
local IGNITE_DURATION_SECONDS = 4

-- 只有会触发点燃的法师火焰伤害技能暴击，才允许刷新 IgniteCheck。
-- Nampower 直接提供技能 ID 与暴击标记；名称白名单只负责筛掉其他法术。
local IgniteTriggerFireSpells = {
    ["火球术"] = true,
    ["火焰冲击"] = true,
    ["灼烧"] = true,
    ["炎爆术"] = true,
    ["烈焰风暴"] = true,
    ["冲击波"] = true,
}

local function IsIgniteSpell(spellId)
    if tonumber(spellId) == IGNITE_SPELL_ID then
        return true
    end
    return GetMageSpellNameByID(spellId) == "点燃"
end

local function IsIgniteTriggerFireSpell(spellId)
    local spellName = GetMageSpellNameByID(spellId)
    return spellName and IgniteTriggerFireSpells[spellName] == true
end

-- hitInfo 是位标记；暴击位为2。旧版 Lua 不使用取模运算符，手动取低两位。
local function IsCriticalSpellDamage(hitInfo)
    local value = tonumber(hitInfo) or 0
    local lowTwoBits = value - math.floor(value / 4) * 4
    return lowTwoBits >= 2
end

local function GetMagePlayerGuid()
    local basic = Cat2.PlayerInformation and Cat2.PlayerInformation.basic
    if basic and basic.guid then
        return basic.guid
    end
    local exists
    local guid
    exists, guid = UnitExists("player")
    return guid
end

local function IsMagePlayerGuid(guid)
    local playerGuid = GetMagePlayerGuid()
    return guid and playerGuid and guid == playerGuid
end

local function IsIgniteTargetGuid(targetGuid)
    if type(targetGuid) ~= "string" or targetGuid == "" or targetGuid == "0x0000000000000000" then
        return false
    end
    return true
end

local function DispatchIgniteDamage(targetGUID, changeType)
    local damage = IgniteDamage[targetGUID]
    if IgniteOwnership[targetGUID] == IGNITE_OWNERSHIP_MINE and
       type(changeType) == "string" and type(damage) == "number" and Cat2.DispatchCardInternalEvent then
        Cat2.DispatchCardInternalEvent("CAT2_MAGE_IGNITE_CHANGED", {
            changeType = changeType,
            targetGUID = targetGUID,
            damage = damage,
        })
    end
end

local function ClearIgniteTarget(targetGuid, showEnd)
    if showEnd and IgniteOwnership[targetGuid] == IGNITE_OWNERSHIP_MINE then
        DispatchIgniteDamage(targetGuid, "END")
    end
    IgniteDamage[targetGuid] = nil
    IgniteCheck[targetGuid] = nil
    IgniteLastTickCheck[targetGuid] = nil
    IgniteOwnership[targetGuid] = nil
end

local function ConfirmPlayerIgnite(targetGuid)
    if not IsIgniteTargetGuid(targetGuid) then
        return false
    end
    local wasMine = IgniteOwnership[targetGuid] == IGNITE_OWNERSHIP_MINE
    IgniteOwnership[targetGuid] = IGNITE_OWNERSHIP_MINE
    if not wasMine and type(IgniteDamage[targetGuid]) == "number" then
        DispatchIgniteDamage(targetGuid, "START")
    end
    return true
end

local function ConfirmOtherIgnite(targetGuid)
    if not IsIgniteTargetGuid(targetGuid) then
        return false
    end
    if IgniteOwnership[targetGuid] == IGNITE_OWNERSHIP_MINE then
        DispatchIgniteDamage(targetGuid, "END")
    end
    IgniteDamage[targetGuid] = nil
    IgniteCheck[targetGuid] = nil
    IgniteLastTickCheck[targetGuid] = nil
    IgniteOwnership[targetGuid] = IGNITE_OWNERSHIP_OTHER
    return true
end

-- 将一次可触发点燃的暴击加入当前每跳预测。只有归属已确认是自己时才对外显示更新；
-- 未确认时保留候选数值，等待 AURA_CAST 或第一跳结构化伤害事件确认。
local function AddIgniteCriticalContribution(targetGuid, criticalDamage)
    if not IsIgniteTargetGuid(targetGuid) or type(criticalDamage) ~= "number" then
        return false
    end

    local hadDamage = type(IgniteDamage[targetGuid]) == "number"
    if not IgniteOwnership[targetGuid] then
        IgniteOwnership[targetGuid] = IGNITE_OWNERSHIP_PENDING
    end

    local igniteTotalContribution = math.floor(criticalDamage * 0.4)
    if IgniteCheck[targetGuid] and IgniteLastTickCheck[targetGuid] then
        local remainingDamage = IgniteDamage[targetGuid] or 0
        IgniteDamage[targetGuid] = math.floor((remainingDamage + igniteTotalContribution) / 2)
    else
        local addedPerTickDamage = math.floor(igniteTotalContribution / 2)
        IgniteDamage[targetGuid] = (IgniteDamage[targetGuid] or 0) + addedPerTickDamage
    end

    IgniteLastTickCheck[targetGuid] = nil
    IgniteCheck[targetGuid] = GetTime()
    if IgniteOwnership[targetGuid] == IGNITE_OWNERSHIP_MINE then
        DispatchIgniteDamage(targetGuid, hadDamage and "DAMAGE" or "START")
    end
    return true
end

local function RecordPlayerIgniteTick(targetGuid, damage)
    if not IsIgniteTargetGuid(targetGuid) or type(damage) ~= "number" then
        return false
    end

    local wasMine = IgniteOwnership[targetGuid] == IGNITE_OWNERSHIP_MINE
    IgniteDamage[targetGuid] = damage
    IgniteOwnership[targetGuid] = IGNITE_OWNERSHIP_MINE
    if not IgniteCheck[targetGuid] then
        IgniteCheck[targetGuid] = GetTime()
    end
    DispatchIgniteDamage(targetGuid, wasMine and "DAMAGE" or "START")

    if IgniteLastTickCheck[targetGuid] then
        ClearIgniteTarget(targetGuid, true)
    else
        IgniteLastTickCheck[targetGuid] = IgniteCheck[targetGuid]
    end
    return true
end



local function ResetData()
    MageArcaneMissilesDuration = 0
    MageArcaneMissilesTimer = 0
    MageChanneledSpellID = 0
    MageChanneledSpellName = nil
    PendingMageChanneledSpellName = nil
    PendingMageChanneledSpellTimer = 0
    MageArcaneSurgeNoSW = 0
    MageArcaneSurge = 0
    MageArcaneSurgeGUID = 0
    MageIcicleDuration = 0
    MageIcicleTimer = 0
    IgniteDamage = {}
    IgniteCheck = {}
    IgniteLastTickCheck = {}
    IgniteOwnership = {}
end



local function OnEvent()

    -- 进入游戏世界刷新常量值
    if event == "PLAYER_ENTERING_WORLD" then
        ResetData()

    -- 离开战斗事件
    elseif event == "PLAYER_REGEN_ENABLED" then
        ResetData()

    -- 玩家死亡，重置一些参数
    elseif event == "PLAYER_DEAD" then
        ResetData()


    -- 施法事件处理，读条类，读条也要处理GCD
    elseif event == "SPELLCAST_START" then

        -- 读条处理
        if arg1 == "炎爆术" then MageCastPyroblastTimer=GetTime()+(arg2/1000)+0.5 end

    elseif event == "SPELLCAST_CHANNEL_START" then
        MageArcaneMissilesDuration = tonumber(arg1) or 0
        MageArcaneMissilesTimer = GetTime()
        if not Cat2.SuperWoW then
            MageChanneledSpellID = 0
            MageChanneledSpellName = GetNampowerMageChanneledSpellName()
                or GetNativeMageChanneledSpellName()
            if not MageChanneledSpellName and PendingMageChanneledSpellName
                and GetTime() - PendingMageChanneledSpellTimer <= 2 then
                MageChanneledSpellName = PendingMageChanneledSpellName
            end
            PendingMageChanneledSpellName = nil
            PendingMageChanneledSpellTimer = 0
        end

    elseif event == "SPELLCAST_CHANNEL_UPDATE" then
        MageArcaneMissilesDuration = tonumber(arg1) or 0
        -- UPDATE 的参数是从当前时刻开始计算的剩余毫秒数，起点也必须同步刷新，
        -- 否则会再次扣除从 CHANNEL_START 到现在已经过去的时间。
        MageArcaneMissilesTimer = GetTime()

    elseif event == "SPELLCAST_CHANNEL_STOP" then
        MageArcaneMissilesDuration = 0
        MageArcaneMissilesTimer = 0
        MageChanneledSpellID = 0
        MageChanneledSpellName = nil
        PendingMageChanneledSpellName = nil
        PendingMageChanneledSpellTimer = 0


    elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then

        if string.find( arg1, ".*抵抗.*" ) or string.find( arg1 or "", "resisted" ) then
            MageArcaneSurgeNoSW = GetTime()
        elseif string.find( arg1, ".*炎爆术.*" ) or string.find( arg1 or "", "Pyroblast" ) then
            MagePyromaniac = 0
        end

    elseif event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" then

        if string.find( arg1, "你获得了法术连击的效果.*" ) or string.find( arg1 or "", "You gain the effect of " .. Cat2.L.Buff("法术连击") ) then
            local number = Cat2.ExtractNumber(arg1) 
            if number then
                MagePyromaniac = Cat2.ToNumber(number)
            else
                MagePyromaniac = 1
            end
        end

    ---------------------------
    -- SuperWoW事件 -----------
    ---------------------------

    -- 施法、攻击事件处理
    elseif event == "SPELL_GO_SELF" then
        -- 同时安装两个扩展时只采用一个成功来源，避免重复推进/刷新计时。
        if not Cat2.SuperWoW then
            RecordFlamestrikeSuccess(arg2)
        end

    elseif event == "UNIT_CASTEVENT" then

        -- 施法事件监测
        if arg3 == "CHANNEL" then

            if arg1 == Cat2.PlayerInformation.basic.guid then
                MageArcaneMissilesTimer = GetTime()
                MageChanneledSpellID = arg4 or 0
                MageChanneledSpellName = nil
                PendingMageChanneledSpellName = nil
                PendingMageChanneledSpellTimer = 0
            end

        elseif arg3 == "CAST" then

            -- 仅监控自己放出的技能
            if arg1 == Cat2.PlayerInformation.basic.guid then
                RecordFlamestrikeSuccess(arg4)

                --print(arg4)

                -- 奥术涌动
                if arg4 == 51936 then
                    MageArcaneSurge = 0

                -- 灼烧
                elseif arg4==2948 or arg4==8444 or arg4==8445 or arg4==8446 or arg4==10205 or arg4==10206 or arg4==10207 then
                    ScorchDelayTime[arg2] = GetTime()

                -- 火焰冲击
                elseif arg4==2136 or arg4==2137 or arg4==2138 or arg4==8412 or arg4==8413 or arg4==10197 or arg4==10199 then
                    FireBlastDelayTime[arg2] = GetTime()

                -- 奥术飞弹
                elseif arg4==7268 or arg4==7269 or arg4==7270 or arg4==8419 or arg4==8418 or arg4==10273 or arg4==10274 or arg4==25346 then


                end



            end

        end

    ---------------------------
    -- Nampower结构化伤害事件 -
    ---------------------------

    elseif event == "SPELL_DAMAGE_EVENT_SELF" then
        local targetGuid = arg1
        local spellId = arg3
        local amount = tonumber(arg4)
        local hitInfo = arg6

        if IsIgniteSpell(spellId) then
            RecordPlayerIgniteTick(targetGuid, amount)
        elseif amount and IsCriticalSpellDamage(hitInfo) and IsIgniteTriggerFireSpell(spellId) then
            AddIgniteCriticalContribution(targetGuid, amount)
        end

    elseif event == "SPELL_DAMAGE_EVENT_OTHER" then
        local targetGuid = arg1
        local casterGuid = arg2
        local spellId = arg3
        local amount = tonumber(arg4)
        local hitInfo = arg6

        if IsIgniteSpell(spellId) then
            if IsMagePlayerGuid(casterGuid) then
                RecordPlayerIgniteTick(targetGuid, amount)
            else
                ConfirmOtherIgnite(targetGuid)
            end
        elseif IgniteOwnership[targetGuid] == IGNITE_OWNERSHIP_MINE and
               amount and IsCriticalSpellDamage(hitInfo) and IsIgniteTriggerFireSpell(spellId) then
            -- 其他法师的火焰暴击会滚入当前点燃；归属仍由随后的点燃跳伤 casterGuid 最终确认。
            AddIgniteCriticalContribution(targetGuid, amount)
        end

    elseif event == "AURA_CAST_ON_OTHER" then
        local spellId = arg1
        local casterGuid = arg2
        local targetGuid = arg3
        if IsIgniteSpell(spellId) then
            if IsMagePlayerGuid(casterGuid) and IgniteOwnership[targetGuid] ~= IGNITE_OWNERSHIP_OTHER then
                ConfirmPlayerIgnite(targetGuid)
            elseif IgniteOwnership[targetGuid] ~= IGNITE_OWNERSHIP_MINE then
                -- 已由真实跳伤确认归我的滚动点燃，不因其他法师的一次刷新直接改判。
                ConfirmOtherIgnite(targetGuid)
            end
        end

    elseif event == "DEBUFF_REMOVED_OTHER" then
        local targetGuid = arg1
        local spellId = arg3
        if IsIgniteSpell(spellId) then
            ClearIgniteTarget(targetGuid, true)
        end

    -- 战斗日志事件处理
    elseif event == "RAW_COMBATLOG" then

        -- 自己的攻击
        if arg1 == "CHAT_MSG_SPELL_SELF_DAMAGE" then

            --print(arg2)

if string.find( arg2, ".*抵抗.*" ) or string.find( arg2 or "", "resisted" ) then
                local guid = Cat2.MatchGUID(arg2)
                if guid then
                    MageArcaneSurge = GetTime()
                    MageArcaneSurgeGUID = guid
                end
            end

            -- 灼烧
            if string.find( arg2, "你的灼烧被.*抵抗.*" ) or string.find( arg2 or "", Cat2.L.Spell("灼烧") .. " was resisted" ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and ScorchDelayTime[targetGUID] then 
                    local timer = GetTime() - ScorchDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        ScorchDelayTime[targetGUID] = nil
                    end
                end
            end

            -- 火焰冲击
            if string.find( arg2, "你的火焰冲击被.*抵抗.*" ) or string.find( arg2 or "", Cat2.L.Spell("火焰冲击") .. " was resisted" ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and FireBlastDelayTime[targetGUID] then 
                    local timer = GetTime() - FireBlastDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        FireBlastDelayTime[targetGUID] = nil
                    end
                end
            end

        end

    elseif event == "BUFF_REMOVED_SELF" then

        --print(arg3)

        -- 气定神闲 消耗
        if arg3 == 12043 then
            -- 取出气定的时间，单位分钟
            local minutes = tonumber(Cat2.Match(Cat2.GetSpellTooltip("气定神闲"), "(%d+%.?%d*)分钟冷却时间"))
            local seconds = minutes * 60
            MageCalmTimer = GetTime()+seconds
        end

    end


end

-- 设置事件处理函数
frame:SetScript("OnEvent", OnEvent)


-- 获取奥术涌动状态
function Cat2.GetMageArcaneSurge()
    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW then
        if GetTime()-MageArcaneSurgeNoSW<4 then
            return true
        end

        return false
    end

	if GetTime()-MageArcaneSurge<4 then

		-- 是否存在有效目标
		local a,guid=UnitExists("target")
		if not guid then
			return false
		end

		-- 校验GUID是否是触发奥术涌动的目标
		if guid == MageArcaneSurgeGUID then
			return true
		end
	end

	return false

end



-- 炎爆术弹道时间
function Cat2.GetMageCastPyroblastTimer()
    return MageCastPyroblastTimer
end

-- 获取指定目标身上视为属于玩家的点燃每跳伤害。
-- targetGUID：目标 GUID；mine 与 pending 都返回当前每跳伤害，明确属于其他玩家或无点燃时返回 0。
function Cat2.GetMageIgniteDamage(targetGUID)
    if not targetGUID or IgniteOwnership[targetGUID] == IGNITE_OWNERSHIP_OTHER then
        return 0
    end
    return IgniteDamage[targetGUID] or 0
end

-- 判断指定目标当前的点燃是否可供卡片按玩家点燃处理。
-- targetGUID：目标 GUID；mine 与 pending 返回 true，明确属于其他玩家或无点燃时返回 false。
function Cat2.IsPlayerIgnite(targetGUID)
    if not targetGUID then
        return false
    end
    return IgniteOwnership[targetGUID] == IGNITE_OWNERSHIP_MINE
        or IgniteOwnership[targetGUID] == IGNITE_OWNERSHIP_PENDING
end

-- 获取指定目标身上视为属于玩家的点燃预计剩余时间。
-- mine 与 pending 按最后一次触发/刷新时间计算；明确属于其他玩家、无点燃或已超时返回 0。
function Cat2.GetMageIgniteRemaining(targetGUID)
    if not targetGUID or IgniteOwnership[targetGUID] == IGNITE_OWNERSHIP_OTHER then
        return 0
    end

    local startedAt = IgniteCheck[targetGUID]
    if type(startedAt) ~= "number" then
        return 0
    end

    local remaining = IGNITE_DURATION_SECONDS - (GetTime() - startedAt)
    if remaining <= 0 then
        return 0
    end
    return remaining
end

-- 获取奥术飞弹持续时间
function Cat2.GetMageArcaneMissilesDuration()
    return MageArcaneMissilesDuration
end

-- 获取奥术飞弹持续剩余时间
function Cat2.GetMageArcaneMissiles()

    local timer = GetTime()-MageArcaneMissilesTimer

    if MageArcaneMissilesDuration <= 0 then
        return -1
    end

    return MageArcaneMissilesDuration/1000 - timer
end


-- 法师断条施法入口：只允许中断名称已确认的奥术飞弹；其他引导识别失败时保持保护。
function Cat2.CastMageWithArcaneMissilesInterrupt(spellName)
    if Cat2.GetChanneled() > 0 then
        local channeledSpellName = MageChanneledSpellName
        if MageChanneledSpellID and MageChanneledSpellID ~= 0 then
            channeledSpellName = GetMageSpellNameByID(MageChanneledSpellID)
        elseif not channeledSpellName then
            channeledSpellName = GetNampowerMageChanneledSpellName()
                or GetNativeMageChanneledSpellName()
            MageChanneledSpellName = channeledSpellName
        end

        if channeledSpellName and MageInterruptibleChannelNames[channeledSpellName] then
            SpellStopCasting()
            CastSpellByName(spellName)
            return true
        end

        return false
    end

    Cat2.Cast(spellName)
    return true
end


-- 获取当前目标是否有火焰易伤效果
-- 注：SuperWow支持更加准确
-- return 存在返回真

local function GetScorchDotCheck( guid )
    if ScorchCheck[guid] then
        local timer = GetTime() - ScorchCheck[guid]
        if timer < 30 then
            return true
        end
    end

    return false
end

function Cat2.GetFireDot()

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["火焰易伤"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists("target")
    if not guid then
        return false
    end

        -- 0.2秒监测期里
    if ScorchDelayTime[guid] then 
        local timer = GetTime() - ScorchDelayTime[guid]
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 计算层数
            if not GetScorchDotCheck(guid) then
                FireVulnerabilityLayer[guid]=1
            else
                if FireVulnerabilityLayer[guid] < 5 then
                    FireVulnerabilityLayer[guid] = FireVulnerabilityLayer[guid] + 1
                end
            end

            -- 已经过了认证期
            ScorchCheck[guid] = ScorchDelayTime[guid]
            ScorchDelayTime[guid] = nil

        end
    end


    if FireBlastDelayTime[guid] then 
        local timer = GetTime() - FireBlastDelayTime[guid]
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 计算层数
            if not GetScorchDotCheck(guid) then
                FireVulnerabilityLayer[guid]=1
            else
                if FireVulnerabilityLayer[guid] < 5 then
                    FireVulnerabilityLayer[guid] = FireVulnerabilityLayer[guid] + 1
                end
            end

            -- 已经过了认证期
            ScorchCheck[guid] = FireBlastDelayTime[guid]
            FireBlastDelayTime[guid] = nil

        end
    end


    return GetScorchDotCheck(guid)
end


function Cat2.GetScorchCheck()
    return ScorchCheck
end

function Cat2.GetFireVulnerabilityLayer()
    return FireVulnerabilityLayer
end

-- 统一判断当前目标是否存在五层火焰易伤。无 SuperWoW 时读取目标 Debuff 的实际层数；
-- SuperWoW 环境沿用本模块的命中确认与层数记录，避免两张燃烧分支各自实现不同逻辑。
function Cat2.HasFiveFireVulnerabilityStacks(targetGUID)
    if not UnitExists("target") then
        return false
    end

    if not Cat2.SuperWoW then
        local applications = Cat2.GetDebuffApplications("Interface\\Icons\\Spell_Fire_SoulBurn", "target") or 0
        return applications >= 5
    end

    if not Cat2.GetFireDot() then
        return false
    end

    local guid = targetGUID
    if not guid then
        local exists
        exists, guid = UnitExists("target")
    end
    return guid and (FireVulnerabilityLayer[guid] or 0) >= 5
end



function Cat2.MageCalmReady()
    if not Cat2.PlayerInformation.temporary.buff["气定神闲"] then
        if Cat2.SpellReady("气定神闲") then
            if MageCalmTimer<GetTime() then
                return true
            end
        end
    end

    return false
end

