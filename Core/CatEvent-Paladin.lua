local _, playerClass = UnitClass("player")
if playerClass ~= "PALADIN" then
    return  -- 终止文件执行
end


-- 创建一个 Frame 并监听事件
local frame = CreateFrame("Frame")

frame:RegisterEvent("SPELLCAST_START")
frame:RegisterEvent("SPELLCAST_STOP")
frame:RegisterEvent("SPELLCAST_FAILED")
frame:RegisterEvent("SPELLCAST_INTERRUPTED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
frame:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")

-- SuperWow专有事件
frame:RegisterEvent("UNIT_CASTEVENT")
frame:RegisterEvent("RAW_COMBATLOG")






-- 圣骑士 十字军打击监测
local CrusaderStrikeCheck = 0

-- 正义圣印续存
local PaladinSealJustice = false
local PaladinSealJusticeDuration = 0
-- 命令圣印续存
local PaladinSealCommand = false
local PaladinSealCommandDuration = 0
-- 智慧圣印续存
local PaladinSealWisdom = false
local PaladinSealWisdomDuration = 0
-- 十字军圣印续存
local PaladinSealCrusader = false
local PaladinSealCrusaderDuration = 0
-- 光明圣印续存
local PaladinSealRight = false
local PaladinSealRightDuration = 0

-- 神圣威能的持续时间
local PaladinHolyStrikeDuration = 0
-- 狂热的持续时间
local PaladinFrenzyLayer = 0
local PaladinFrenzyDuration = 0


local function OnEvent()

    if event == "PLAYER_REGEN_ENABLED" then
        CrusaderStrikeCheck = 0

    -- 玩家死亡，重置参数
    elseif event == "PLAYER_DEAD" then
        CrusaderStrikeCheck = 0

        PaladinSealJustice = false
        PaladinSealCommand = false
        PaladinSealWisdom = false
        PaladinSealCrusader = false
        PaladinSealRight = false
        PaladinSealJusticeDuration = 0
        PaladinSealWisdomDuration = 0
        PaladinSealCrusaderDuration = 0
        PaladinSealCommandDuration = 0
        PaladinSealRightDuration = 0

    -- 施法事件处理，读条类，读条也要处理GCD
    elseif event == "SPELLCAST_START" then

    elseif event == "SPELLCAST_STOP" then

    elseif event == "SPELLCAST_FAILED" then

    elseif event == "SPELLCAST_INTERRUPTED" then

    elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then

        -- 神圣打击 - 无论是否命中、招架、闪避，都能刷新威能
        if string.find( arg1, "你的神圣打击.*" ) then
            PaladinHolyStrikeDuration = GetTime()
        elseif string.find( arg1, "你的十字军打击.*" ) then
            PaladinFrenzyDuration = GetTime()
            CrusaderStrikeCheck = GetTime()
        elseif string.find( arg1, "你的.*审判.*" ) then
            PaladinSealJustice = false
            PaladinSealCommand = false
            PaladinSealWisdom = false
            PaladinSealCrusader = false
            PaladinSealRight = false
            gcdtimer = 0
        end

    elseif event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" then
        --message(arg1)
        --message("---SPELLCAST_STOP-----")

        if string.find( arg1, "你获得了狂热的效果.*" ) then
            local number = Cat2.ExtractNumber(arg1) 
            if number then
                PaladinFrenzyLayer = Cat2.ToNumber(number)
            else
                PaladinFrenzyLayer = 1
            end
        elseif string.find( arg1, "你获得了正义圣印的效果.*" ) then
            PaladinSealJustice = true
            PaladinSealCommand = false
            PaladinSealWisdom = false
            PaladinSealCrusader = false
            PaladinSealRight = false

            PaladinSealJusticeDuration = GetTime()
            PaladinSealWisdomDuration = 0
            PaladinSealCrusaderDuration = 0
            PaladinSealCommandDuration = 0
            PaladinSealRightDuration = 0

        elseif string.find( arg1, "你获得了命令圣印的效果.*" ) then
            PaladinSealJustice = false
            PaladinSealCommand = true
            PaladinSealWisdom = false
            PaladinSealCrusader = false
            PaladinSealRight = false

            PaladinSealJusticeDuration = 0
            PaladinSealWisdomDuration = 0
            PaladinSealCrusaderDuration = 0
            PaladinSealCommandDuration = GetTime()
            PaladinSealRightDuration = 0

        elseif string.find( arg1, "你获得了智慧圣印的效果.*" ) then
            PaladinSealJustice = false
            PaladinSealCommand = false
            PaladinSealWisdom = true
            PaladinSealCrusader = false
            PaladinSealRight = false

            PaladinSealWisdomDuration = GetTime()
            PaladinSealJusticeDuration = 0
            PaladinSealCrusaderDuration = 0
            PaladinSealCommandDuration = 0
            PaladinSealRightDuration = 0

        elseif string.find( arg1, "你获得了十字军圣印的效果.*" ) then
            PaladinSealJustice = false
            PaladinSealCommand = false
            PaladinSealWisdom = false
            PaladinSealCrusader = true
            PaladinSealRight = false

            PaladinSealCrusaderDuration = GetTime()
            PaladinSealJusticeDuration = 0
            PaladinSealWisdomDuration = 0
            PaladinSealCommandDuration = 0
            PaladinSealRightDuration = 0

        elseif string.find( arg1, "你获得了光明圣印的效果.*" ) then
            PaladinSealJustice = false
            PaladinSealCommand = false
            PaladinSealWisdom = false
            PaladinSealCrusader = false
            PaladinSealRight = true

            PaladinSealCrusaderDuration = 0
            PaladinSealJusticeDuration = 0
            PaladinSealWisdomDuration = 0
            PaladinSealCommandDuration = 0
            PaladinSealRightDuration = GetTime()

        end

    elseif event == "CHAT_MSG_SPELL_AURA_GONE_SELF" then
        --message(arg1)
        --message("---CHAT_MSG_SPELL_AURA_GONE_SELF-----")

        if string.find( arg1, ".*狂热效果.*消失.*" ) then
            if not Cat2.SuperWoW then
                PaladinFrenzyLayer = 0
            end
        elseif string.find( arg1, ".*圣印.*消失.*" ) then

            PaladinSealJustice = false
            PaladinSealCommand = false
            PaladinSealWisdom = false
            PaladinSealCrusader = false
            PaladinSealRight = false
            
            PaladinSealJusticeDuration = 0
            PaladinSealWisdomDuration = 0
            PaladinSealCrusaderDuration = 0
            PaladinSealCommandDuration = 0
            PaladinSealRightDuration = 0
            
        end



    ---------------------------
    -- SuperWoW事件 -----------
    ---------------------------

    -- 施法、攻击事件处理
    elseif event == "UNIT_CASTEVENT" then

        if arg3 == "CAST" then

            -- 仅监控自己放出的技能
            if arg1 == Cat2.PlayerInformation.basic.guid then

                --message(arg4)

                -- 正义圣印
                if arg4==21084 or arg4==20287 or arg4==20288 or arg4==20289 or arg4==20290 or arg4==20291 or arg4==20292 or arg4==20293 then
                    Cat2.Msg("正义圣印")
                    PaladinSealJusticeDuration = GetTime()
                    PaladinSealWisdomDuration = 0
                    PaladinSealCrusaderDuration = 0
                    PaladinSealCommandDuration = 0
                    PaladinSealRightDuration = 0
                -- 命令圣印
                elseif arg4==20920 or arg4==20919 or arg4==20918 or arg4==20915 or arg4==20375 then
                    Cat2.Msg("命令圣印")
                    PaladinSealJusticeDuration = 0
                    PaladinSealWisdomDuration = 0
                    PaladinSealCrusaderDuration = 0
                    PaladinSealCommandDuration = GetTime()
                    PaladinSealRightDuration = 0
                -- 智慧圣印
                elseif arg4==20166 or arg4==20356 or arg4==20357 or arg4==51745 or arg4 == 51746 then
                    Cat2.Msg("智慧圣印")
                    PaladinSealWisdomDuration = GetTime()
                    PaladinSealJusticeDuration = 0
                    PaladinSealCrusaderDuration = 0
                    PaladinSealCommandDuration = 0
                    PaladinSealRightDuration = 0

                -- 十字军圣印
                elseif arg4==21082 or arg4==20162 or arg4==20305 or arg4==20306 or arg4==20307 or arg4==20308 then
                    Cat2.Msg("十字军圣印")
                    PaladinSealCrusaderDuration = GetTime()
                    PaladinSealJusticeDuration = 0
                    PaladinSealWisdomDuration = 0
                    PaladinSealCommandDuration = 0
                    PaladinSealRightDuration = 0
                -- 光明圣印
                elseif arg4==20165 or arg4==20347 or arg4==20348 or arg4==20349 then
                    Cat2.Msg("光明圣印")
                    PaladinSealCrusaderDuration = 0
                    PaladinSealJusticeDuration = 0
                    PaladinSealWisdomDuration = 0
                    PaladinSealCommandDuration = 0
                    PaladinSealRightDuration = GetTime()

                -- 审判
                elseif arg4 == 20271 then
                    Cat2.Msg("审判")
                    PaladinSealJusticeDuration = 0
                    PaladinSealWisdomDuration = 0
                    PaladinSealCrusaderDuration = 0
                    PaladinSealCommandDuration = 0
                    PaladinSealRightDuration = 0
                    gcdtimer = 0        -- 审判不会触发GCD

                -- 十字军打击
                elseif arg4 == 10337 then
                    if Cat2.GetCrusaderStrike() then
                        PaladinFrenzyLayer = PaladinFrenzyLayer +1
                        if PaladinFrenzyLayer>3 then PaladinFrenzyLayer=3 end
                    else
                        PaladinFrenzyLayer = 1
                    end
                    PaladinFrenzyDuration = GetTime()
                    CrusaderStrikeCheck = GetTime()

                -- 神圣打击
                elseif arg4 == 10333 then
                    PaladinHolyStrikeDuration = GetTime()
                end

            end
        end

    -- 战斗日志事件处理
    elseif event == "RAW_COMBATLOG" then

    end

end

-- 设置事件处理函数
frame:SetScript("OnEvent", OnEvent)


-- 获取自己是否有圣印效果
-- 注：SuperWow支持更加准确
-- return 存在返回真
function Cat2.Seal(name)

	if name=="正义圣印" then
		if GetTime()-PaladinSealJusticeDuration<30 then
			return true
		end
	elseif name=="智慧圣印" then
		if GetTime()-PaladinSealWisdomDuration<30 then
			return true
		end
	elseif name=="十字军圣印" then
		if GetTime()-PaladinSealCrusaderDuration<30 then
			return true
		end
	elseif name=="命令圣印" then
		if GetTime()-PaladinSealCommandDuration<30 then
			return true
		end
	elseif name=="光明圣印" then
		if GetTime()-PaladinSealRightDuration<30 then
			return true
		end
	end

	return false
end

-- 获取十字军打击的狂热是否存在
function Cat2.GetCrusaderStrike()

	if (GetTime()-PaladinFrenzyDuration)<30 then
		return true
	end

    PaladinFrenzyLayer = 0
	return false

end

-- 获取十字军打击的狂热的时间
function Cat2.GetCrusaderStrikeDuration()
    return PaladinFrenzyDuration
end

-- 获取狂热的层数
function Cat2.GetFrenzyLayer()
    return PaladinFrenzyLayer
end

-- 获取神圣威能的时间
function Cat2.GetHolyStrikeDuration()
    return PaladinHolyStrikeDuration
end


