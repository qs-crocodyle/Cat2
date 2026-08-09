local _, playerClass = UnitClass("player")
if playerClass ~= "HUNTER" then
    return  -- 终止文件执行
end

local frame = CreateFrame("Frame")

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
frame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
frame:RegisterEvent("START_AUTOREPEAT_SPELL")
frame:RegisterEvent("STOP_AUTOREPEAT_SPELL")

frame:RegisterEvent("SPELLCAST_CHANNEL_START")
frame:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
frame:RegisterEvent("SPELLCAST_CHANNEL_STOP")
frame:RegisterEvent("SPELLCAST_DELAYED")
frame:RegisterEvent("SPELLCAST_INTERRUPTED")
frame:RegisterEvent("SPELLCAST_STOP")
frame:RegisterEvent("SPELLCAST_START")
frame:RegisterEvent("SPELLS_CHANGED")

-- SuperWow专有事件
frame:RegisterEvent("UNIT_CASTEVENT")
frame:RegisterEvent("RAW_COMBATLOG")


-- 等待技能反馈的等待时间
local BLEENCHECKDELAY = 0.3

local SerpentCheck = {}
local SerpentDelayTime = {}
local ScorpidCheck = {}
local ScorpidDelayTime = {}
local ViperCheck = {}
local ViperDelayTime = {}

-- 割伤 激活时间
local HunterGoreTimer = 0

-- 自动射击状态
local HunterAutoShot = 0

-- 自动射击 周期
local HunterShotDuration = 3
local HunterShotTimer = 100

local function ResetData()
    SerpentCheck = {}
    SerpentDelayTime = {}
    ScorpidCheck = {}
    ScorpidDelayTime = {}
    ViperCheck = {}
    ViperDelayTime = {}
end


-- 猎人印记黑名单
local hunterMarkBlockList = {

	-- K40
    ["阿诺玛鲁斯"] = true,
    ["Anomalus"] = true,

	-- TAQ
    ["维克洛尔大帝"] = true,
    ["Vek'lor"] = true,
    ["维克尼拉斯大帝"] = true,
    ["Vek'nilash"] = true,
}

-- 检测单位是否吃猎人印记
--- return boolean can 返回真，否则返回假
function Cat2.IsHunterMark(unit)
	unit = unit or "target"
	local name = UnitName(unit)

	if not name then
		return false
	end

	-- 判断猎人印记名单
	if hunterMarkBlockList[name] == true then
		return false
	end

	return true
end



-- 奥术射击黑名单
local hunterArcaneShotBlockList = {
	-- K40
    ["阿诺玛鲁斯"] = true,
    ["Anomalus"] = true,

	-- TAQ
    ["维克洛尔大帝"] = true,
    ["Vek'lor"] = true,
    ["维克尼拉斯大帝"] = true,
    ["Vek'nilash"] = true,
}

-- 检测单位是否吃奥术射击
--- return boolean can 返回真，否则返回假
function Cat2.IsHunterArcaneShot(unit)
	unit = unit or "target"
	local name = UnitName(unit)

	if not name then
		return false
	end

	-- 判断奥术射击名单
	if hunterArcaneShotBlockList[name] == true then
		return false
	end

	return true
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

        --message(arg1)
        -- 牧师治疗读条处理
        --if arg1 == "自动射击" then print("自动射击") end

    elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then

        if not Cat2.SuperWoW then
            if string.find( arg1, ".*你的自动射击.*" ) or string.find( arg1 or "", "Your Auto Shot" ) then
                HunterShotTimer = GetTime()
                HunterShotDuration = UnitRangedDamage("player")
            end
        end
        
        if string.find( arg1, ".*致命一击.*" ) or string.find( arg1 or "", "crits" ) then
            HunterGoreTimer = GetTime()+4

        -- 奥术射击 - 异常免疫目标记录
        elseif string.find( arg1, ".*奥术射击.*免疫.*" ) or string.find( arg1 or "", "Your Arcane Shot" ) and string.find( arg1 or "", "immune" ) then

            local targetName = UnitName("target")
            if targetName then
                -- 将该目标加入表（临时，重登后丢失）
                hunterArcaneShotBlockList[targetName] = true
            end

        -- 猎人印记 - 异常免疫目标记录
        elseif string.find( arg1, ".*猎人印记.*免疫.*" ) or string.find( arg1 or "", "Your Hunters Mark" ) and string.find( arg1 or "", "immune" ) then

            local targetName = UnitName("target")
            if targetName then
                -- 将该目标加入表（临时，重登后丢失）
                hunterMarkBlockList[targetName] = true
            end

        -- 毒蛇钉刺 - 异常免疫目标记录
        elseif string.find( arg1, ".*毒蛇钉刺.*免疫.*" ) or string.find( arg1 or "", "Your Serpent Sting" ) and string.find( arg1 or "", "immune" ) then

            local targetName = UnitName("target")
            if targetName then
                --DEFAULT_CHAT_FRAME:AddMessage(MPTipsColor.."发现["..targetName.."]免疫毒蛇钉刺。")
                -- 将该目标加入表（临时，重登后丢失）
                --MPPosionBlcokList[targetName] = true
            end

        end

        --print(arg1)

    elseif event == "CHAT_MSG_COMBAT_SELF_HITS" then

        if string.find( arg1, ".*致命一击.*" ) or string.find( arg1 or "", "crits" ) then
            HunterGoreTimer = GetTime()+4
        end

    elseif event == "START_AUTOREPEAT_SPELL" then

        HunterAutoShot = 1

    elseif event == "STOP_AUTOREPEAT_SPELL" then

        HunterAutoShot = 0

    ---------------------------
    -- SuperWoW事件 -----------
    ---------------------------

    -- 施法、攻击事件处理
    elseif event == "UNIT_CASTEVENT" then

        -- 仅监控自己
        if arg1 == Cat2.PlayerInformation.basic.guid then

            -- 施法事件监测
            if arg3 == "CAST" then

                -- 毒蛇钉刺
                if arg4==1978 or arg4==13549 or arg4==13550 or arg4==13551 or arg4==13552 or arg4==13553 or arg4==13554 or arg4==13555 or arg4==25295 then
                    SerpentDelayTime[arg2] = GetTime()

                -- 蝰蛇钉刺
                elseif arg4==14280 and arg4==14280 and arg4==14280 then
                    ViperDelayTime[arg2] = GetTime()

                -- 毒蝎钉刺
                elseif arg4==3043 then
                    ScorpidDelayTime[arg2] = GetTime()

                -- 自动射击
                elseif arg4==75 then
                    HunterShotTimer = GetTime()
                    HunterShotDuration = UnitRangedDamage("player")

                end

            end
        end

    -- 战斗日志事件处理
    elseif event == "RAW_COMBATLOG" then

        -- 自己的攻击
        if arg1 == "CHAT_MSG_SPELL_SELF_DAMAGE" then

            if string.find( arg2, "你的毒蛇钉刺.*招架.*" ) or string.find( arg2, "你的毒蛇钉刺.*躲闪.*" ) or string.find( arg2, "你的毒蛇钉刺.*格挡.*" ) or string.find( arg2, "你的毒蛇钉刺.*没有击中.*" ) or ( string.find(arg2 or "", "Your Serpent Sting") and ( string.find(arg2 or "", "dodg") or string.find(arg2 or "", "parr") or string.find(arg2 or "", "block") or string.find(arg2 or "", "miss") ) ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and SerpentDelayTime[targetGUID] then 
                    local timer = GetTime() - SerpentDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        SerpentDelayTime[targetGUID] = nil
                    end
                end
            elseif string.find( arg2, "你的蝰蛇钉刺.*招架.*" ) or string.find( arg2, "你的蝰蛇钉刺.*躲闪.*" ) or string.find( arg2, "你的蝰蛇钉刺.*格挡.*" ) or string.find( arg2, "你的蝰蛇钉刺.*没有击中.*" ) or ( string.find(arg2 or "", "Your Viper Sting") and ( string.find(arg2 or "", "dodg") or string.find(arg2 or "", "parr") or string.find(arg2 or "", "block") or string.find(arg2 or "", "miss") ) ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and ViperDelayTime[targetGUID] then 
                    local timer = GetTime() - ViperDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        ViperDelayTime[targetGUID] = nil
                    end
                end
            elseif string.find( arg2, "你的毒蝎钉刺.*招架.*" ) or string.find( arg2, "你的毒蝎钉刺.*躲闪.*" ) or string.find( arg2, "你的毒蝎钉刺.*格挡.*" ) or string.find( arg2, "你的毒蝎钉刺.*没有击中.*" ) or ( string.find(arg2 or "", "Your Scorpid Sting") and ( string.find(arg2 or "", "dodg") or string.find(arg2 or "", "parr") or string.find(arg2 or "", "block") or string.find(arg2 or "", "miss") ) ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and ScorpidDelayTime[targetGUID] then 
                    local timer = GetTime() - ScorpidDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        ScorpidDelayTime[targetGUID] = nil
                    end
                end
            end

        end

    end


end

-- 设置事件处理函数
frame:SetScript("OnEvent", OnEvent)



-- 获取自动射击标记
function Cat2.GetAutoShot()
    return HunterAutoShot
end


-- 获取自动射击剩余时间
-- return 返回下一次自动射击的剩余时间
function Cat2.GetHunterShotLeft()
    local t = GetTime() - HunterShotTimer
    local left = HunterShotDuration - t;

    if left < 0 then
        return 0
    end

    return left
end

-- 获取自动射击消耗掉的时间
function Cat2.GetHunterShotTime()
    return GetTime() - HunterShotTimer
end




-- 获取当前目标是否有毒蛇钉刺
-- 注：SuperWow支持更加准确
-- return 存在返回真

local function GetSerpentStingDOTCheck( guid )

    if SerpentCheck[guid] then
        local timer = GetTime() - SerpentCheck[guid]
        if timer < 14 then
            return true
        end
    end

    return false
end

function Cat2.GetSerpentStingDot(unit)

    unit = unit or "target"

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["毒蛇钉刺"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists(unit)
    if not guid then
        return false
    end

    if SerpentDelayTime[guid] then 
        local timer = GetTime() - SerpentDelayTime[guid]
        -- 0.2秒监测期里
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            SerpentCheck[guid] = SerpentDelayTime[guid]
            SerpentDelayTime[guid] = nil
        end
    end

    return GetSerpentStingDOTCheck(guid)
end

function Cat2.GetSerpentStingCheck()
    return SerpentCheck
end




-- 获取当前目标是否有毒蝎钉刺
-- 注：SuperWow支持更加准确
-- return 存在返回真

local function GetScorpidStingDOTCheck( guid )

    if ScorpidCheck[guid] then
        local timer = GetTime() - ScorpidCheck[guid]
        if timer < 19 then
            return true
        end
    end

    return false
end

function Cat2.GetScorpidStingDot(unit)

    unit = unit or "target"

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["毒蝎钉刺"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists(unit)
    if not guid then
        return false
    end

    if ScorpidDelayTime[guid] then 
        local timer = GetTime() - ScorpidDelayTime[guid]
        -- 0.2秒监测期里
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            ScorpidCheck[guid] = ScorpidDelayTime[guid]
            ScorpidDelayTime[guid] = nil
        end
    end

    return GetScorpidStingDOTCheck(guid)
end

function Cat2.GetScorpidStingCheck()
    return ScorpidCheck
end





-- 获取当前目标是否有蝰蛇钉刺
-- 注：SuperWow支持更加准确
-- return 存在返回真

local function GetViperStingDOTCheck( guid )

    if ViperCheck[guid] then
        local timer = GetTime() - ViperCheck[guid]
        if timer < 8 then
            return true
        end
    end

    return false
end

function Cat2.GetViperStingDot(unit)

    unit = unit or "target"

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["蝰蛇钉刺"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists(unit)
    if not guid then
        return false
    end

    if ViperDelayTime[guid] then 
        local timer = GetTime() - ViperDelayTime[guid]
        -- 0.2秒监测期里
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            ViperCheck[guid] = ViperDelayTime[guid]
            ViperDelayTime[guid] = nil
        end
    end

    return GetViperStingDOTCheck(guid)
end

function Cat2.GetViperStingCheck()
    return ViperCheck
end


function Cat2.GetHunterGoreAllow()
    if GetTime()-HunterGoreTimer<0 then
        return true
    end

    return false
end



