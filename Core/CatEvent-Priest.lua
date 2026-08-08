local _, playerClass = UnitClass("player")
if playerClass ~= "PRIEST" then
    return  -- 终止文件执行
end


-- 创建一个 Frame 并监听事件
local frame = CreateFrame("Frame")

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("SPELLCAST_START")
frame:RegisterEvent("SPELLCAST_STOP")
frame:RegisterEvent("SPELLCAST_FAILED")
frame:RegisterEvent("SPELLCAST_INTERRUPTED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_DEAD")

frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
frame:RegisterEvent("SPELLCAST_CHANNEL_START")
frame:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
frame:RegisterEvent("SPELLCAST_CHANNEL_STOP")


-- SuperWow专有事件
frame:RegisterEvent("UNIT_CASTEVENT")
frame:RegisterEvent("RAW_COMBATLOG")



-- 真言术：痛事件管理
local PainCheck = {}
local PainDelayTime = {}

-- 吸血鬼的拥抱事件管理
local VampiricCheck = {}
local VampiricDelayTime = {}

-- 神圣之火事件管理
local HolyFireCheck = {}
local HolyFireDelayTime = {}


-- 等待技能反馈的等待时间
local BLEENCHECKDELAY = 0.2

-- 引导法术持续状态
local ChanneledDuration = 0
local ChanneledTimer = 0

-- 鞭笞 阶段
local MindFlayCount = 0

-- 痛 持续时间
local PainDuration = 18
function Cat2.SetPainDuration(value)
    value = value or 18
    PainDuration = value
end

-- 祈祷之书
local PriestPrayerBookCount = 0

-- 神圣之火 施法状态
local CastHolyFireTimer = 0


local function OnEvent()

    -- 离开战斗事件，重置参数
    if event == "PLAYER_REGEN_ENABLED" then
        ChanneledDuration = 0
        ChanneledTimer = 0
        MindFlayCount = 0

    -- 进入游戏世界刷新常量值
    elseif event == "PLAYER_ENTERING_WORLD" then
        PainCheck = {}
        PainDelayTime = {}
        VampiricCheck = {}
        VampiricDelayTime = {}
        ChanneledDuration = 0
        ChanneledTimer = 0
        MindFlayCount = 0

    -- 玩家死亡，重置参数
    elseif event == "PLAYER_DEAD" then
        PainCheck = {}
        PainDelayTime = {}
        VampiricCheck = {}
        VampiricDelayTime = {}
        ChanneledDuration = 0
        ChanneledTimer = 0
        MindFlayCount = 0

    -- 施法事件处理，读条类，读条也要处理GCD
    elseif event == "SPELLCAST_START" then

        if arg1 == "神圣之火" then
            CastHolyFireTimer=GetTime()+(arg2/1000)+0.3
        end

    elseif event == "SPELLCAST_STOP" then


    elseif event == "SPELLCAST_FAILED" then


    elseif event == "SPELLCAST_INTERRUPTED" then

        CastHolyFireTimer = -1

    elseif event == "SPELLCAST_CHANNEL_START" then
        ChanneledDuration = arg1
        ChanneledTimer = GetTime()
        MindFlayCount = 0

    elseif event == "SPELLCAST_CHANNEL_UPDATE" then
        ChanneledDuration = arg1

    elseif event == "SPELLCAST_CHANNEL_STOP" then
        ChanneledDuration = 0
        ChanneledTimer = 0
        MindFlayCount = 0

    elseif event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" then
        --print(arg1)

        if string.find(arg1, "你的精神鞭笞使.*") then
            MindFlayCount = MindFlayCount + 1
        end

    ---------------------------
    -- SuperWoW事件 -----------
    ---------------------------

    -- 施法、攻击事件处理
    elseif event == "UNIT_CASTEVENT" then

        if arg3 == "CAST" then
            -- 仅监控自己放出的技能
            if arg1 == Cat2.PlayerInformation.basic.guid then

                --MPMsg(arg4)
                

                -- 暗言术：痛
                if arg4==589 or arg4==594 or arg4==970 or arg4==992 or arg4==2767 or arg4==10892 or arg4==10893 or arg4==10894 then
                    PainDelayTime[arg2] = GetTime()
                    --[[
                    -- 暗言术：痛 计算持续时间
                    PainDuration = 18 + Cat2.IsTalentLearned(3,4)*3
                    if Cat2.CheckInventoryItemName(13,"休眠腐化之眼") then PainDuration=PainDuration+3 end
                    if Cat2.CheckInventoryItemName(14,"休眠腐化之眼") then PainDuration=PainDuration+3 end
                    ]]
                -- 吸血鬼的拥抱
                elseif arg4==15286 then
                    VampiricDelayTime[arg2] = GetTime()

                -- 神圣之火
                elseif arg4==14914 or arg4==15262 or arg4==15263 or arg4==15264 or arg4==15265 or arg4==15266 or arg4==15267 or arg4==15261 then
                    HolyFireDelayTime[arg2] = GetTime()

                -- 恢复
                elseif arg4==139 or arg4==6074 or arg4==6075 or arg4==6076 or arg4==6077 or arg4==6078 or arg4==10927 or arg4==10928 or arg4==10929 or arg4==25315 then
                    PriestPrayerBookCount = 1

                -- 快速治疗
                elseif arg4==2061 or arg4==9472 or arg4==9473 or arg4==9474 or arg4==10915 or arg4==10916 or arg4==10917 then
                    PriestPrayerBookCount = 2

                -- 强效治疗术
                elseif arg4==2060 or arg4==10963 or arg4==10964 or arg4==10965 or arg4==25314 then
                    PriestPrayerBookCount = 3

                -- 治疗祷言
                elseif arg4==596 or arg4==996 or arg4==10960 or arg4==10961 or arg4==25316 then
                    PriestPrayerBookCount = 4

                end

            end
        end

    -- 战斗日志事件处理
    elseif event == "RAW_COMBATLOG" then

        -- 自己的攻击
        if arg1 == "CHAT_MSG_SPELL_SELF_DAMAGE" then

            -- 暗言术：痛
            if string.find( arg2, "你的暗言术：痛被.*抵抗.*" ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and PainDelayTime[targetGUID] then 
                    local timer = GetTime() - PainDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        PainDelayTime[targetGUID] = nil
                    end
                end
            end

            -- 吸血鬼的拥抱
            if string.find( arg2, "你的吸血鬼的拥抱被.*抵抗.*" ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and VampiricDelayTime[targetGUID] then 
                    local timer = GetTime() - VampiricDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        VampiricDelayTime[targetGUID] = nil
                    end
                end
            end

            -- 神圣之火
            if string.find( arg2, "你的神圣之火被.*抵抗.*" ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and HolyFireDelayTime[targetGUID] then 
                    local timer = GetTime() - HolyFireDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        HolyFireDelayTime[targetGUID] = nil
                    end
                end
            end

        end
    end

end

-- 设置事件处理函数
frame:SetScript("OnEvent", OnEvent)




-- 获取当前目标是否有暗言术：痛
-- 注：SuperWow支持更加准确
-- return 存在返回真

local function GetPainDOTCheck( guid, value )

    if PainCheck[guid] then
        local timer = GetTime() - PainCheck[guid]
        if timer < PainDuration then
            return true
        end
    end

    return false
end

function Cat2.GetPainDot(unit, value)

    unit = unit or "target"
    value = value or 0

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.Buff("暗言术：痛",unit)
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists(unit)
    if not guid then
        return false
    end

    if PainDelayTime[guid] then 
        local timer = GetTime() - PainDelayTime[guid]
        -- 0.2秒监测期里
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            PainCheck[guid] = PainDelayTime[guid]
            PainDelayTime[guid] = nil
        end
    end

    return GetPainDOTCheck(guid,value)
end

function Cat2.GetPainCheck()
    return PainCheck
end



-- 获取当前目标是否有吸血鬼的拥抱
-- 注：SuperWow支持更加准确
-- return 存在返回真

function GetVampiricDOTCheck( guid, value )

    if VampiricCheck[guid] then
        local timer = GetTime() - VampiricCheck[guid]
        if timer < (60-value) then
            return true
        end
    end

    return false
end

function Cat2.GetVampiricDot(unit, value)

    unit = unit or "target"
    value = value or 0

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.Buff("吸血鬼的拥抱",unit)
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists(unit)
    if not guid then
        return false
    end

    if VampiricDelayTime[guid] then 
        local timer = GetTime() - VampiricDelayTime[guid]
        -- 0.2秒监测期里
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            VampiricCheck[guid] = VampiricDelayTime[guid]
            VampiricDelayTime[guid] = nil
        end
    end

    return GetVampiricDOTCheck(guid,value)
end

function Cat2.GetVampiricCheck()
    return VampiricCheck
end



-- 获取当前目标是否有神圣之火
-- 注：SuperWow支持更加准确
-- return 存在返回真

local function GetHolyFireDOTCheck( guid, value )

    if HolyFireCheck[guid] then
        local timer = GetTime() - HolyFireCheck[guid]
        if timer < (10-value) then
            return true
        end
    end

    return false
end

function Cat2.GetHolyFireDot(unit, value)

    unit = unit or "target"
    value = value or 0

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.Buff("神圣之火",unit)
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists(unit)
    if not guid then
        return false
    end

    if HolyFireDelayTime[guid] then 
        local timer = GetTime() - HolyFireDelayTime[guid]
        -- 0.2秒监测期里
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            HolyFireCheck[guid] = HolyFireDelayTime[guid]
            HolyFireDelayTime[guid] = nil
        end
    end

    return GetHolyFireDOTCheck(guid, value)
end










-- 获取引导时间
function Cat2.GetPriestChanneledDuration()
    return ChanneledDuration
end

-- 获取引导持续剩余时间
function Cat2.GetPriestChanneled()

    -- 安全边界检查
    if ChanneledDuration and ChanneledDuration==0 then
        return 0
    end

    local timer = GetTime()-ChanneledTimer

    if timer > ChanneledDuration then
        return 0
    end


    return ChanneledDuration/1000 - timer
end

-- 获取鞭笞阶段
function Cat2.GetPriestMindFlayCount()
    return MindFlayCount
end


-- 获取神圣之火
function Cat2.GetCastHolyFireTimer()
    return CastHolyFireTimer
end


