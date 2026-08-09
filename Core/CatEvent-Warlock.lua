local _, playerClass = UnitClass("player")
if playerClass ~= "WARLOCK" then
    return  -- 终止文件执行
end

local frame = CreateFrame("Frame")

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
frame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
frame:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")

frame:RegisterEvent("SPELLCAST_START")
frame:RegisterEvent("SPELLCAST_STOP")
frame:RegisterEvent("SPELLCAST_CHANNEL_START")
frame:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
frame:RegisterEvent("SPELLCAST_CHANNEL_STOP")

-- SuperWow专有事件
frame:RegisterEvent("UNIT_CASTEVENT")
frame:RegisterEvent("RAW_COMBATLOG")

-- Nampower专有事件
frame:RegisterEvent("SPELL_CHANNEL_START")



-- 痛苦诅咒事件管理
local CurseAgonyCheck = {}
local CurseAgonyDelayTime = {}
-- 痛苦诅咒持续时间
local CurseAgonyDuration = 24
function Cat2.SetCurseAgonyDuration(value)
    value = value or 24
    CurseAgonyDuration = value
end

-- 腐蚀术事件管理
local CorruptionCheck = {}
local CorruptionDelayTime = {}

local CorruptionTimer = 0
function Cat2.GetCorruptionTimer()
    return CorruptionTimer
end
-- 腐蚀术持续时间
local WarlockCorruptionDuration = 18
function Cat2.SetWarlockCorruptionDuration(value)
    value = value or 18
    WarlockCorruptionDuration = value
end

-- 生命虹吸事件管理
local SiphonLifeCheck = {}
local SiphonLifeDelayTime = {}
-- 生命虹吸持续时间
local WarlockSiphonLifeDuration = 30
function Cat2.SetWarlockSiphonLifeDuration(value)
    value = value or 18
    WarlockSiphonLifeDuration = value
end

-- 献祭事件管理
local ImmolateCheck = {}
local ImmolateDelayTime = {}

local ImmolateTimer = 0
function Cat2.GetImmolateTimer()
    return ImmolateTimer
end
-- 献祭持续时间
local WarlockImmolateDuration = 15
function Cat2.SetWarlockImmolateDuration(value)
    value = value or 15
    WarlockImmolateDuration = value
end

-- 等待技能反馈的等待时间
local BLEENCHECKDELAY = 0.2

-- 引导法术持续状态
local ChanneledDuration = 0
local ChanneledSpellID = 0
local ChanneledTimer = 0


local ShadowTwilightTimer = 0

-- 施放潜力
local PotentialTimer = 0
local PotentialLayer = 0

-- 生命通道，特例处理，由于生命通道没有具体消息，故需要特例进行计算
local LifeChannel = false
local LifeChannelTimer = 0

local ManaChannel = false



local function ResetData()
    CurseAgonyCheck = {}
    CurseAgonyDelayTime = {}

    CorruptionCheck = {}
    CorruptionDelayTime = {}

    SiphonLifeCheck = {}
    SiphonLifeDelayTime = {}

    ImmolateCheck = {}
    ImmolateDelayTime = {}

    ChanneledDuration = 0
    ChanneledTimer = 0

    PotentialTimer = 0
    PotentialLayer = 0

    LifeChannel = false
    LifeChannelTimer = 0
    ManaChannel = false
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

    elseif event == "SPELLCAST_CHANNEL_START" then
        ChanneledDuration = arg1
        if not Cat2.SuperWoW then
            ChanneledTimer = GetTime()
        end

    elseif event == "SPELLCAST_CHANNEL_UPDATE" then
        ChanneledDuration = arg1

    elseif event == "SPELLCAST_CHANNEL_STOP" then
        ChanneledDuration = 0
        ChanneledTimer = 0
        ChanneledSpellID = 0


    -- 施法事件处理，读条类
    elseif event == "SPELLCAST_START" then

        if arg1 == "献祭" or arg1 == "Immolate" then ImmolateTimer=GetTime()+2
        elseif arg1 == "腐蚀术" or arg1 == "Corruption" then CorruptionTimer=GetTime()+1.6 end

    elseif event == "SPELLCAST_STOP" then


    -- buff获得
    elseif event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" then

        if string.find( arg1, "获得了释放潜力的效果" ) or string.find( arg1 or "", "gain the effect of Release" ) then
            if string.find( arg1, UnitName("player") ) then
                PotentialTimer = GetTime()
                local number = Cat2.ExtractNumber(arg1) 
                if number then
                    PotentialLayer = Cat2.ToNumber(number)
                    if PotentialLayer==0 then
                        PotentialLayer=1
                    end
                else
                    PotentialLayer = 1
                end
            end

        elseif string.find( arg1, "从法力通道获得" ) or string.find( arg1 or "", "gain mana from" ) then
            if string.find( arg1, UnitName("player") ) then
                ManaChannel = true
                if Cat2.GetPotential() and PotentialLayer>0 then
                    PotentialTimer = GetTime()
                end
            end

        elseif string.find( arg1, "获得了生命通道的效果" ) or string.find( arg1 or "", "gain the effect of Life Channel" ) then
            if string.find( arg1, UnitName("player") ) then
                LifeChannel = true
                LifeChannelTimer = GetTime()
            end
        end

    -- buff 消失
    elseif event == "CHAT_MSG_SPELL_AURA_GONE_SELF" then

        if string.find( arg1, "生命通道效果从" ) or string.find( arg1 or "", "Life Channel (.-) fades" ) then
            if string.find( arg1, UnitName("player") ) then
                LifeChannel = false
            end
        elseif string.find( arg1, "法力通道效果从" ) or string.find( arg1 or "", "Mana Channel (.-) fades" ) then
            if string.find( arg1, UnitName("player") ) then
                ManaChannel = false
            end
        end

    elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then

        if string.find( arg1, ".*致命一击.*" ) or string.find( arg1 or "", "crits" ) then
            if Cat2.GetPotential() and PotentialLayer>0 then
                PotentialTimer = GetTime()
            end
        end

    ---------------------------
    -- SuperWoW事件 -----------
    ---------------------------

    -- 施法、攻击事件处理
    elseif event == "UNIT_CASTEVENT" then

        if arg3 == "CHANNEL" then

            if arg1 == Cat2.PlayerInformation.basic.guid then
            

                ChanneledTimer = GetTime()
                ChanneledSpellID = arg4

                if not Cat2.Nampower4 then
                    if arg4==52550 or arg4==52551 or arg4==52552 then

                        Cat2.Msg( Cat2.L("施放 [暗影收割]") .. string.format("%.2f",arg5/1000) .. Cat2.L("重新计算DOT持续时间") )

                        -- 痛苦诅咒
                        if Cat2.GetCurseAgonyDot() then
                            if CurseAgonyCheck[arg2] then
                                CurseAgonyCheck[arg2] = CurseAgonyCheck[arg2] - (arg5/2000) + 0.6
                            end
                        end

                        -- 腐蚀术
                        if Cat2.GetCorruptionDot() then
                            if CorruptionCheck[arg2] then
                                CorruptionCheck[arg2] = CorruptionCheck[arg2] - (arg5/2000) + 0.6
                            end
                        end

                        -- 生命虹吸
                        if Cat2.GetSiphonLifeDot() then
                            if SiphonLifeCheck[arg2] then
                                SiphonLifeCheck[arg2] = SiphonLifeCheck[arg2] - (arg5/2000) + 0.6
                            end
                        end
                    end
                end

            end

        -- 施法事件监测
        elseif arg3 == "CAST" then

            -- 仅监控自己放出的技能
            if arg1 == Cat2.PlayerInformation.basic.guid then

                --MPMsg(arg4)

                -- 痛苦诅咒
                if arg4==980 or arg4==1014 or arg4==6217 or arg4==11711 or arg4==11712 or arg4 == 11713 then
                    -- 计算应该持续时间
                    CurseAgonyDelayTime[arg2] = GetTime()

                -- 腐蚀术
                elseif arg4==172 or arg4==6222 or arg4==6223 or arg4==7648 or arg4==11671 or arg4==11672 or arg4==25311 then
                    CorruptionDelayTime[arg2] = GetTime()

                -- 生命虹吸
                elseif arg4==18265 or arg4==18879 or arg4==18880 or arg4==18881 then
                    SiphonLifeDelayTime[arg2] = GetTime()

                -- 献祭
                elseif arg4==348 or arg4==707 or arg4==1094 or arg4==2941 or arg4==11665 or arg4==11667 or arg4==11668 or arg4==25309 then
                    --MPMsg("献祭 目标="..arg2)
                    ImmolateDelayTime[arg2] = GetTime()

                -- 燃烧
                elseif arg4==17962 or arg4==18930 or arg4==18931 or arg4==18932 then
                    if ImmolateDelayTime[arg2] then 
                        local timer = GetTime() - ImmolateDelayTime[arg2]
                        -- 0.2秒监测期里
                        if timer <= BLEENCHECKDELAY then
                            ImmolateDelayTime[arg2] = ImmolateDelayTime[arg2] - 3.0
                        end
                    else
                        if ImmolateCheck[arg2] then
                            ImmolateCheck[arg2] = ImmolateCheck[arg2] - 3.0
                        end
                    end

                -- 顺发 暗影箭
                elseif arg4==686 or arg4==11660 or arg4==11661 or arg4==25307 then
                    ShadowTwilightTimer = GetTime()

                end
            end

        end

    -- 战斗日志事件处理
    elseif event == "RAW_COMBATLOG" then

        -- 自己的攻击
        if arg1 == "CHAT_MSG_SPELL_SELF_DAMAGE" then

            --message(arg2)

            -- 痛苦诅咒
            if string.find( arg2, "你的痛苦诅咒被.*抵抗.*" ) or string.find( arg2 or "", "Your Curse of Agony was resisted" ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and CurseAgonyDelayTime[targetGUID] then 
                    local timer = GetTime() - CurseAgonyDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        CurseAgonyDelayTime[targetGUID] = nil
                    end
                end
            elseif string.find( arg2, "你的腐蚀术被.*抵抗.*" ) or string.find( arg2 or "", "Your Corruption was resisted" ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and CorruptionDelayTime[targetGUID] then 
                    local timer = GetTime() - CorruptionDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        CorruptionDelayTime[targetGUID] = nil
                    end
                end
            elseif string.find( arg2, "你的生命虹吸被.*抵抗.*" ) or string.find( arg2 or "", "Your Siphon Life was resisted" ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and SiphonLifeDelayTime[targetGUID] then 
                    local timer = GetTime() - SiphonLifeDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        SiphonLifeDelayTime[targetGUID] = nil
                    end
                end
            elseif string.find( arg2, "你的献祭被.*抵抗.*" ) or string.find( arg2 or "", "Your Immolate was resisted" ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and ImmolateDelayTime[targetGUID] then 
                    local timer = GetTime() - ImmolateDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        ImmolateDelayTime[targetGUID] = nil
                    end
                end
            end

        end

    -- Nampower专有事件

    elseif event == "SPELL_CHANNEL_START" then

        if arg1==52550 or arg1==52551 or arg1==52552 then
            Cat2.Msg( Cat2.L("施放 [暗影收割]") .. string.format("%.2f",arg3/1000) .. Cat2.L("重新计算DOT持续时间") )

            -- 痛苦诅咒
            if Cat2.GetCurseAgonyDot() then
                if CurseAgonyCheck[arg2] then
                    CurseAgonyCheck[arg2] = CurseAgonyCheck[arg2] - (arg3/2000) + 0.4
                end
            end

            -- 腐蚀术
            if Cat2.GetCorruptionDot() then
                if CorruptionCheck[arg2] then
                    CorruptionCheck[arg2] = CorruptionCheck[arg2] - (arg3/2000) + 0.4
                end
            end

            -- 生命虹吸
            if Cat2.GetSiphonLifeDot() then
                if SiphonLifeCheck[arg2] then
                    SiphonLifeCheck[arg2] = SiphonLifeCheck[arg2] - (arg3/2000) + 0.4
                end
            end

        end

    end


end


local function OnUpdate()

    -- 特例计算生命通道
    if LifeChannel then
        if GetTime()-LifeChannelTimer >= 1 then
            LifeChannelTimer = GetTime()
            if Cat2.GetPotential() and PotentialLayer>0 then
                PotentialTimer = GetTime()
            end
        end
    end

end


-- 设置事件处理函数
frame:SetScript("OnEvent", OnEvent)
frame:SetScript("OnUpdate", OnUpdate)





-- 获取当前目标是否有痛苦诅咒
-- 注：SuperWow支持更加准确
-- return 存在返回真

local function GetCurseAgonyDOTCheck( guid, value )

    if CurseAgonyCheck[guid] then
        local timer = GetTime() - CurseAgonyCheck[guid]
        if timer < (CurseAgonyDuration-value) then
            return true
        end
    end

    return false
end

function Cat2.GetCurseAgonyDot(unit, value)

    unit = unit or "target"
    value = value or 0

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["痛苦诅咒"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists(unit)
    if not guid then
        return false
    end

    if CurseAgonyDelayTime[guid] then 
        local timer = GetTime() - CurseAgonyDelayTime[guid]
        -- 0.2秒监测期里
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            CurseAgonyCheck[guid] = CurseAgonyDelayTime[guid]
            CurseAgonyDelayTime[guid] = nil
        end
    end

    return GetCurseAgonyDOTCheck(guid, value)
end


function Cat2.GetCurseAgonyCheck()
    return CurseAgonyCheck
end


-- 获取当前目标是否有腐蚀术
-- 注：SuperWow支持更加准确
-- return 存在返回真

function GetCorruptionDOTCheck( guid, value )

    if CorruptionCheck[guid] then
        local timer = GetTime() - CorruptionCheck[guid]
        if timer < (WarlockCorruptionDuration-value) then
            return true
        end
    end

    return false
end

function Cat2.GetCorruptionDot(unit, value)

    unit = unit or "target"
    value = value or 0

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["腐蚀术"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists(unit)
    if not guid then
        return false
    end

    if CorruptionDelayTime[guid] then 
        local timer = GetTime() - CorruptionDelayTime[guid]
        -- 0.2秒监测期里
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            CorruptionCheck[guid] = CorruptionDelayTime[guid]
            CorruptionDelayTime[guid] = nil
        end
    end

    return GetCorruptionDOTCheck(guid, value)
end


function Cat2.GetCorruptionCheck()
    return CorruptionCheck
end



-- 获取当前目标是否有生命虹吸
-- 注：SuperWow支持更加准确
-- return 存在返回真

local function GetSiphonLifeDOTCheck( guid, value )

    if SiphonLifeCheck[guid] then
        local timer = GetTime() - SiphonLifeCheck[guid]
        if timer < (WarlockSiphonLifeDuration-value) then
            return true
        end
    end

    return false
end

function Cat2.GetSiphonLifeDot(unit, value)

    unit = unit or "target"
    value = value or 0

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["生命虹吸"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists(unit)
    if not guid then
        return false
    end

    if SiphonLifeDelayTime[guid] then 
        local timer = GetTime() - SiphonLifeDelayTime[guid]
        -- 0.2秒监测期里
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            SiphonLifeCheck[guid] = SiphonLifeDelayTime[guid]
            SiphonLifeDelayTime[guid] = nil
        end
    end

    return GetSiphonLifeDOTCheck(guid, value)
end


function Cat2.GetSiphonLifeCheck()
    return SiphonLifeCheck
end






-- 获取当前目标是否有献祭
-- 注：SuperWow支持更加准确
-- return 存在返回真

local function GetImmolateDOTCheck( guid, value )

    if ImmolateCheck[guid] then
        local timer = GetTime() - ImmolateCheck[guid]
        if timer < (WarlockImmolateDuration-value) then
            return true
        end
    end

    return false
end

function Cat2.GetImmolateDot(unit, value)

    unit = unit or "target"
    value = value or 0

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["献祭"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists(unit)
    if not guid then
        return false
    end

    if ImmolateDelayTime[guid] then 
        local timer = GetTime() - ImmolateDelayTime[guid]
        -- 0.2秒监测期里
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            ImmolateCheck[guid] = ImmolateDelayTime[guid]
            ImmolateDelayTime[guid] = nil
        end
    end

    return GetImmolateDOTCheck(guid, value)
end


function Cat2.GetImmolateCheck()
    return ImmolateCheck
end


-- 获取引导时间
function Cat2.GetWarlockChanneledDuration()
    return ChanneledDuration
end

-- 获取引导持续剩余时间
function Cat2.GetWarlockChanneled()
    local timer = GetTime()-ChanneledTimer

    if timer > ChanneledDuration then
        return 0
    end

    return ChanneledDuration/1000 - timer
end

-- 获取当前读条技能id
function Cat2.GetWarlockChanneledSpellID()
    return ChanneledSpellID
end

-- 获取施放潜力
function Cat2.GetPotential()
    if GetTime()-PotentialTimer<20 then
        return true
    end

    return false
end

function Cat2.GetPotentialTimer()
    return PotentialTimer
end
function Cat2.GetPotentialLayer()
    return PotentialLayer
end

function Cat2.GetManaChannel()
    return ManaChannel
end

function Cat2.GetLifeChannel()
    return LifeChannel
end

function Cat2.GetShadowTwilightTimer()
    return ShadowTwilightTimer
end


