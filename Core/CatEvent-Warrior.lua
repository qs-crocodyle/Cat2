local _, playerClass = UnitClass("player")
if playerClass ~= "WARRIOR" then
    return  -- 终止文件执行
end

local frame = CreateFrame("Frame")

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
frame:RegisterEvent("UNIT_CASTEVENT")
frame:RegisterEvent("RAW_COMBATLOG")



-- 战斗怒吼持续时间
local WarriorBattleShoutDuration = 120


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

    if event == "PLAYER_REGEN_DISABLED" then

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
        if string.find( arg1, "你发起了攻击.*闪开了.*" ) then
            OverpowerTimerNoSW = GetTime()
        end

    elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
        --print(arg1)
        if string.find( arg1, ".*躲闪.*" ) then
            OverpowerTimerNoSW = GetTime()
        elseif string.find( arg1, ".*压制.*" ) then
            OverpowerTimerNoSW = 0
        elseif string.find( arg1, ".*你的反击对.*" ) then        --这里要完整，反击有个同名反击风暴
            CounterTimerNoSW = 0
        end

    elseif event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES" then
        --MPMsg("SELF_MISSES - "..arg1)
        if string.find( arg1, ".*你招架住了.*" ) then
            CounterTimerNoSW = GetTime()
        elseif string.find( arg1, ".*你闪躲开了.*" ) then
            CounterTimerNoSW = GetTime()
        elseif string.find( arg1, ".*你格挡开了.*" ) then
            CounterTimerNoSW = GetTime()
        end

    elseif event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS" then
        --MPMsg("SELF_HITS - "..arg1)
        if string.find( arg1, ".*被格挡.*" ) then
            CounterTimerNoSW = GetTime()
        end

    elseif event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" then
        if string.find( arg1, "你获得了战斗怒吼的效果.*" ) then
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
            if string.find( arg2, "你发起了攻击.*闪开了.*" ) then
                local guid = Cat2.MatchGUID(arg2)
                if guid then
                    OverpowerTimer = GetTime()
                    OverpowerTargetGUID = guid
                end
            end

        elseif arg1 == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES" then
            if string.find( arg2, ".*你招架住了.*" ) then
                local guid = Cat2.MatchGUID(arg2)
                if guid then
                    CounterTimer = GetTime()
                    CounterTargetGUID = guid
                end
            elseif string.find( arg2, ".*你闪躲开了.*" ) then
                local guid = Cat2.MatchGUID(arg2)
                if guid then
                    CounterTimer = GetTime()
                    CounterTargetGUID = guid
                end
            elseif string.find( arg1, ".*你格挡开了.*" ) then
                local guid = Cat2.MatchGUID(arg2)
                if guid then
                    CounterTimer = GetTime()
                    CounterTargetGUID = guid
                end
            end

        elseif arg1 == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS" then
            if string.find( arg2, ".*被格挡.*" ) then
                local guid = Cat2.MatchGUID(arg2)
                if guid then
                    CounterTimer = GetTime()
                    CounterTargetGUID = guid
                end
            end

        -- 自己的攻击
        elseif arg1 == "CHAT_MSG_SPELL_SELF_DAMAGE" then

            if string.find( arg2, ".*躲闪.*" ) then
                local guid = Cat2.MatchGUID(arg2)
                if guid then
                    OverpowerTimer = GetTime()
                    OverpowerTargetGUID = guid
                end
            end

        elseif arg1 == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" then
            if string.find( arg2, "你的撕裂.*" ) or string.find( arg2, ".*your 撕裂.*" ) then
                local targetGUID = Cat2.MatchGUID(arg2) 
                if targetGUID then
                    RendCheck[targetGUID] = GetTime()
                end
            end

        end

    end


end

-- 设置事件处理函数
frame:SetScript("OnEvent", OnEvent)





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


