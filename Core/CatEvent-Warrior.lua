local _, playerClass = UnitClass("player")
if playerClass ~= "WARRIOR" then
    return  -- 终止文件执行
end

local frame = CreateFrame("Frame")

-- Nampower 结构化事件在未安装 Nampower 的客户端中可能不是合法事件，保护注册以便安全降级。
local function RegisterOptionalEvent(eventName)
    Cat2.RegisterOptionalEvent(frame, eventName)
end

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
frame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
frame:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
frame:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS")
frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")

frame:RegisterEvent("SPELLCAST_START")
frame:RegisterEvent("SPELLCAST_STOP")
frame:RegisterEvent("SPELLCAST_INTERRUPTED")
frame:RegisterEvent("SPELLCAST_FAILED")


-- SuperWow专有事件
RegisterOptionalEvent("UNIT_CASTEVENT")
RegisterOptionalEvent("RAW_COMBATLOG")

-- Nampower专有事件。乱舞状态由近战暴击与后续挥击次数推算，不依赖 Aura 槽位。
RegisterOptionalEvent("AUTO_ATTACK_SELF")
RegisterOptionalEvent("SPELL_DAMAGE_EVENT_SELF")
RegisterOptionalEvent("SPELL_GO_SELF")



-- 战斗怒吼持续时间
local WarriorBattleShoutDuration = 120

-- 乱舞持续时间与剩余攻击次数。即使乱舞超过客户端可读取的32个正面光环槽位，
-- Nampower仍会返回造成暴击和后续挥击的结构化事件，因此可在本地重建状态。
local WARRIOR_FLURRY_DURATION = 15
local WARRIOR_FLURRY_MAX_CHARGES = 3
local WARRIOR_FLURRY_TALENT_TAB = 2
local WARRIOR_FLURRY_TALENT_INDEX = 15
local WarriorFlurryCharges = 0
local WarriorFlurryExpiresAt = 0
local WarriorSpellDataCache = {}

local function ResetWarriorFlurry()
    WarriorFlurryCharges = 0
    WarriorFlurryExpiresAt = 0
end

local function HasWarriorFlurryTalent()
    local _, _, _, _, rank = GetTalentInfo(WARRIOR_FLURRY_TALENT_TAB, WARRIOR_FLURRY_TALENT_INDEX)
    return (tonumber(rank) or 0) > 0
end

local function RefreshWarriorFlurry()
    if not HasWarriorFlurryTalent() then
        ResetWarriorFlurry()
        return
    end

    WarriorFlurryCharges = WARRIOR_FLURRY_MAX_CHARGES
    WarriorFlurryExpiresAt = GetTime() + WARRIOR_FLURRY_DURATION
end

local function ConsumeWarriorFlurryCharge()
    if WarriorFlurryCharges <= 0 then
        return
    end
    if WarriorFlurryExpiresAt > 0 and GetTime() >= WarriorFlurryExpiresAt then
        ResetWarriorFlurry()
        return
    end

    WarriorFlurryCharges = WarriorFlurryCharges - 1
    if WarriorFlurryCharges <= 0 then
        ResetWarriorFlurry()
    end
end

-- 兼容旧版 Lua：不依赖 bit 库检查单个二进制标记。
local function HasEventBit(value, bitValue)
    value = tonumber(value) or 0
    local divided = math.floor(value / bitValue)
    return divided - math.floor(divided / 2) * 2 == 1
end

local function GetWarriorSpellData(spellId)
    spellId = tonumber(spellId)
    if not spellId or spellId <= 0 then
        return nil, nil
    end

    local cached = WarriorSpellDataCache[spellId]
    if cached then
        return cached.name, cached.dmgClass
    end

    local spellName
    local damageClass
    if type(GetSpellRecField) == "function" then
        spellName = GetSpellRecField(spellId, "name")
        damageClass = tonumber(GetSpellRecField(spellId, "dmgClass"))
    end
    if not spellName and type(GetSpellNameAndRankForId) == "function" then
        spellName = GetSpellNameAndRankForId(spellId)
    end

    cached = {
        name = spellName,
        dmgClass = damageClass,
    }
    WarriorSpellDataCache[spellId] = cached
    return cached.name, cached.dmgClass
end

local function IsQueuedSwingSpell(spellName)
    return spellName == "英勇打击" or spellName == "顺劈斩"
end


-- 猛击施法
local WarriorSlamCast = 0
local WarriorSlamCastTimer = 0


-- 战士撕裂监测
local RendCheck = {}

-- 战士破甲监测
local SunderArmorCheck = {}

-- 记录压制时间
local OverpowerTimer = 0
local OverpowerTargetGUID = 0
local OverpowerTimerNoSW = 0

-- 记录反击时间
local CounterTimer = 0
local CounterTargetGUID = 0
local CounterTimerNoSW = 0

-- 战斗怒吼
local BattleShoutTimer = 0


local function OnEvent()

    if event == "PLAYER_ENTERING_WORLD" then
        ResetWarriorFlurry()

    elseif event == "PLAYER_REGEN_DISABLED" then

    -- 离开战斗事件，重置参数
    elseif event == "PLAYER_REGEN_ENABLED" then
        RendCheck = {}
        SunderArmorCheck = {}
        WarriorSlamCast = 0

    -- 玩家死亡，重置参数
    elseif event == "PLAYER_DEAD" then
        RendCheck = {}
        WarriorSlamCast = 0
        BattleShoutTimer = 0
        ResetWarriorFlurry()

    -- 施法事件处理，读条类，读条也要处理GCD
    elseif event == "SPELLCAST_START" then

        if arg1=="猛击" then
            WarriorSlamCast=1
            WarriorSlamCastTimer = GetTime()+(arg2/1000)
        end

    elseif event == "SPELLCAST_STOP" then

        WarriorSlamCastTimer = 0
        WarriorSlamCast = 0

    elseif event == "SPELLCAST_INTERRUPTED" then

        --message("SPELLCAST_INTERRUPTED")
        WarriorSlamCastTimer = 0
        WarriorSlamCast = 0

    elseif event == "SPELLCAST_FAILED" then

        --message("SPELLCAST_FAILED")
        WarriorSlamCastTimer = 0
        WarriorSlamCast = 0

    elseif event == "CHAT_MSG_COMBAT_SELF_MISSES" then
        if string.find( arg1, "你发起了攻击.*闪开了.*" ) or string.find( arg1 or "", "Your attack.*dodg" ) then
            OverpowerTimerNoSW = GetTime()
        end

    elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
        --print(arg1)
        if string.find( arg1, ".*躲闪.*" ) or string.find( arg1 or "", "dodg" ) then
            OverpowerTimerNoSW = GetTime()
        elseif string.find( arg1, ".*压制.*" ) or string.find( arg1 or "", "Overpower" ) then
            OverpowerTimerNoSW = 0
        elseif string.find( arg1, ".*你的反击对.*" ) or string.find( arg1 or "", Cat2.L.Spell("复仇") ) then        --这里要完整，反击有个同名反击风暴
            CounterTimerNoSW = 0
        end

    elseif event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES" then
        --MPMsg("SELF_MISSES - "..arg1)
        if string.find( arg1, ".*你招架住了.*" ) or string.find( arg1 or "", "You parry" ) then
            CounterTimerNoSW = GetTime()
        elseif string.find( arg1, ".*你闪躲开了.*" ) or string.find( arg1 or "", "You dodge" ) then
            CounterTimerNoSW = GetTime()
        elseif string.find( arg1, ".*你格挡开了.*" ) or string.find( arg2 or "", "You block" ) then
            CounterTimerNoSW = GetTime()
        end

    elseif event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS" then
        --MPMsg("SELF_HITS - "..arg1)
        if string.find( arg1, ".*被格挡.*" ) or string.find( arg1 or "", "blocked" ) then
            CounterTimerNoSW = GetTime()
        end

    elseif event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" then
        if string.find( arg1, "你获得了战斗怒吼的效果.*" ) or string.find( arg1 or "", "You gain the effect of " .. Cat2.L.Spell("战斗怒吼") ) then
            BattleShoutTimer = GetTime()
        end


    ---------------------------
    -- SuperWoW事件 -----------
    ---------------------------

    -- 施法、攻击事件处理
    elseif event == "UNIT_CASTEVENT" then

        -- 施法事件监测
        if arg3 == "CAST" then

            -- 仅监控自己放出的技能
            if arg1 == Cat2.PlayerInformation.basic.guid then
                --MPMsg(arg4)

                -- 撕裂 主动
                if arg4 == 11574 then
                    RendCheck[arg2] = GetTime()

                -- 压制
                elseif arg4 == 11585 then
			        OverpowerTimer=0

                -- 反击
                elseif arg4 == 51630 then
			        CounterTimer=0

                -- 战斗怒吼 7级
                elseif arg4==25289 then
                    BattleShoutTimer = GetTime()

                elseif arg4==11597 then
                    SunderArmorCheck[arg2] = GetTime()

                end

            end

        end

    -- 战斗日志事件处理
    elseif event == "RAW_COMBATLOG" then

        if arg1 == "CHAT_MSG_COMBAT_SELF_MISSES" then
            if string.find( arg2, "你发起了攻击.*闪开了.*" ) or string.find( arg2 or "", "Your attack.*dodg" ) then
                local guid = Cat2.MatchGUID(arg2)
                if guid then
                    OverpowerTimer = GetTime()
                    OverpowerTargetGUID = guid
                end
            end

        elseif arg1 == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES" then
            if string.find( arg2, ".*你招架住了.*" ) or string.find( arg2 or "", "You parry" ) then
                local guid = Cat2.MatchGUID(arg2)
                if guid then
                    CounterTimer = GetTime()
                    CounterTargetGUID = guid
                end
            elseif string.find( arg2, ".*你闪躲开了.*" ) or string.find( arg2 or "", "You dodge" ) then
                local guid = Cat2.MatchGUID(arg2)
                if guid then
                    CounterTimer = GetTime()
                    CounterTargetGUID = guid
                end
elseif string.find( arg1, ".*你格挡开了.*" ) or string.find( arg1 or "", "You block" ) then
                local guid = Cat2.MatchGUID(arg2)
                if guid then
                    CounterTimer = GetTime()
                    CounterTargetGUID = guid
                end
            end

        elseif arg1 == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS" then
            if string.find( arg2, ".*被格挡.*" ) or string.find( arg2 or "", "blocked" ) then
                local guid = Cat2.MatchGUID(arg2)
                if guid then
                    CounterTimer = GetTime()
                    CounterTargetGUID = guid
                end
            end

        -- 自己的攻击
        elseif arg1 == "CHAT_MSG_SPELL_SELF_DAMAGE" then

            if string.find( arg2, ".*躲闪.*" ) or string.find( arg2 or "", "dodg" ) then
                local guid = Cat2.MatchGUID(arg2)
                if guid then
                    OverpowerTimer = GetTime()
                    OverpowerTargetGUID = guid
                end
            end

        elseif arg1 == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" then
            if string.find( arg2, "你的撕裂.*" ) or string.find( arg2, ".*your 撕裂.*" ) or string.find( arg2 or "", Cat2.L.Spell("撕裂") ) then
                local targetGUID = Cat2.MatchGUID(arg2) 
                if targetGUID then
                    RendCheck[targetGUID] = GetTime()
                end
            end

        end

    ---------------------------
    -- Nampower结构化攻击事件 -
    ---------------------------

    elseif event == "AUTO_ATTACK_SELF" then
        -- 普攻暴击位为128。触发暴击的这一击最终会把乱舞刷新为3层；
        -- 其他主手/副手攻击结果（包括未命中、闪避、招架）各消耗一层。
        if HasEventBit(arg4, 128) then
            RefreshWarriorFlurry()
        else
            ConsumeWarriorFlurryCharge()
        end

    elseif event == "SPELL_GO_SELF" then
        -- arg2为技能ID。这里只统计服务器已结算的替代挥击，不统计客户端排队请求。
        -- 一次顺劈不论命中几个目标，或英勇/顺劈全部未命中，都只在这里扣一层。
        -- Nampower会先报告GO包内各目标的SPELL_MISS_SELF，再报告一次SPELL_GO_SELF；
        -- 因此不能在逐目标的未命中事件中再次扣层，也不以短时间窗口合并不同挥击。
        local spellName = GetWarriorSpellData(arg2)
        if IsQueuedSwingSpell(spellName) then
            ConsumeWarriorFlurryCharge()
        end

    elseif event == "SPELL_DAMAGE_EVENT_SELF" then
        local _, damageClass = GetWarriorSpellData(arg3)
        if damageClass == 2 then
            -- 技能伤害的暴击位为2；乌龟服所有直接近战技能暴击均可触发乱舞。
            -- 替代挥击已在SPELL_GO_SELF扣层。多目标伤害只负责暴击刷新，
            -- 后续普通命中不会扣掉同一次顺劈刚刷新的乱舞层数。
            if HasEventBit(arg6, 2) then
                RefreshWarriorFlurry()
            end
        end

    end


end

-- 设置事件处理函数
frame:SetScript("OnEvent", OnEvent)


-- 战士乱舞状态。
-- 客户端前32个正面光环中能直接读取到乱舞时立即返回；只有不可见时，才使用
-- Nampower近战暴击事件重建出的三层状态供卡片判断。
function Cat2.WarriorFlurry()
    local information = Cat2.PlayerInformation and Cat2.PlayerInformation.temporary
    if information and information.buff and information.buff["乱舞"] then
        return true
    end

    if not HasWarriorFlurryTalent() then
        ResetWarriorFlurry()
        return false
    end
    if WarriorFlurryCharges <= 0 then
        return false
    end
    if WarriorFlurryExpiresAt > 0 and GetTime() >= WarriorFlurryExpiresAt then
        ResetWarriorFlurry()
        return false
    end

    return true
end





-- 战士撕裂状态
function Cat2.WarriorRend()
    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["撕裂"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists("target")
    if not guid then
        return false
    end

    if RendCheck[guid] then
        if GetTime()-RendCheck[guid] < 3.4 then
            return true
        end
    end

    return false
end

function Cat2.GetWarriorRendValue( GUID )
    if RendCheck[GUID] then
        return RendCheck[GUID]
    end

    return 0
end



-- 获取反击、复仇状态
function Cat2.WarriorCounterAttack()
    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        if GetTime()-CounterTimerNoSW<4 then
            return true
        end

        return false
    end

	if GetTime()-CounterTimer<4 then

		-- 是否存在有效目标
		local a,guid=UnitExists("target")
		if not guid then
			return false
		end

		-- 校验GUID是否是触发压制的目标
		if guid == CounterTargetGUID then
			return true
		end
	end

	return false
end



-- 获取压制状态
function Cat2.WarriorOverpower(LeftTime)
    LeftTime = LeftTime or 4

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        if GetTime()-OverpowerTimerNoSW<LeftTime then
            return true
        end

        return false
    end

	if GetTime()-OverpowerTimer<LeftTime then

		-- 是否存在有效目标
		local a,guid=UnitExists("target")
		if not guid then
			return false
		end

		-- 校验GUID是否是触发压制的目标
		if guid == OverpowerTargetGUID then
			return true
		end
	end

	return false
end



function Cat2.SetBattleShoutDuration(value)
    WarriorBattleShoutDuration = value
end

function Cat2.GetBattleShout()
    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        if Cat2.PlayerInformation.temporary.buff["战斗怒吼"] then
            return WarriorBattleShoutDuration
        else
            return 0
        end
    end

    return WarriorBattleShoutDuration-(GetTime()-BattleShoutTimer)
end

-- 一破的监测
function Cat2.GetSunderArmorOnce()

    local _,guid=UnitExists("target")
	if not guid then
		return false
	end

    if SunderArmorCheck[guid] then
        if GetTime()-SunderArmorCheck[guid]>30 then
            SunderArmorCheck[guid] = nil
        end
        return true
    end

    return false

end


-- 获取当前目标身上由自己最近一次破甲攻击推算出的剩余时间。
-- 1.12 客户端不能直接读取目标 Debuff 到期时间，因此使用 UNIT_CASTEVENT
-- 记录的施放时间和破甲攻击固定的 30 秒持续时间进行计算。
function Cat2.GetSunderArmorRemaining()

    local _,guid = UnitExists("target")
    if not guid then
        return 0
    end

    local appliedAt = SunderArmorCheck[guid]
    if not appliedAt then
        return 0
    end

    local remaining = 30 - (GetTime() - appliedAt)
    if remaining <= 0 then
        SunderArmorCheck[guid] = nil
        return 0
    end

    return remaining

end


-- 猛击中断机制
function Cat2.WarriorSlamStop()

	if WarriorSlamCast==1 then --and GetTime()-MPWarriorSlamCastTimer > 0 then

		-- 正在读条
		SpellStopCasting()

	end

end


-- 英勇打击 顺劈斩 是否激活
function Cat2.WarriorHeroicAction()

    -- print(GetActionText(25))
    -- 我的炉石位置
    -- 用于获取id

	for A=1,172 do
		local _,_,id = GetActionText(A)

        -- 英勇打击 顺劈斩
		if id==25286 or id==20569 or id==45961 then
            --print(A)
            if IsCurrentAction(A) then
                return true
            end
		end
	end

    return false
end

-- 英勇打击类取消
function Cat2.WarriorCancelHeroic()

	-- 这里要先确认英勇打击类已经被激活

    if Cat2.WarriorHeroicAction() then

 	    -- 有目标才处理
	    local _,guid = UnitExists("target")
	    if guid then
		    ClearTarget()
		    TargetUnit(guid)
	    end

    end

	Cat2.StartAttack()

end


