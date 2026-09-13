local _,class = UnitClass("player")
if class ~= "DRUID" then
    return  -- 终止文件执行
end


-- 创建一个 Frame 并监听事件
local frame = CreateFrame("Frame")

frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("UNIT_ENERGY")

frame:RegisterEvent("PLAYER_COMBO_POINTS")

-- SuperWow专有事件
Cat2.RegisterOptionalEvent(frame, "UNIT_CASTEVENT")
Cat2.RegisterOptionalEvent(frame, "RAW_COMBATLOG")



-- 等待技能反馈的等待时间
local BLEENCHECKDELAY = 0.2

-- DOT持续时间的网络延迟减少
local DOT_DURATION_DELAY = 0.01


-- 扫击、撕碎、血袭监测
local RateCheck = {}
local RateDelayTime = {}
local DruidRakeDuration = 9

local RipCheck = {}
local RipDelayTime = {}
local DruidRipDuration = 18

local RavageCheck = {}
local RavageDelayTime = {}
local DruidRavageDuration = 18

-- 流血dot 跳 时间
local DruidRateJumpTimer = 0
local DruidRipJumpTimer = 0

function Cat2.GetDruidRateJumpTimer()
    return DruidRateJumpTimer
end
function Cat2.GetDruidRipJumpTimer()
    return DruidRipJumpTimer
end

-- 猛虎回能 跳 时间
local DruidTigerFuryTimer = 0

function Cat2.GetDruidTigerFuryTimer()
    return DruidTigerFuryTimer
end

-- 回能监测
local OldEnergy = nil
local RestoredEnergyTime = nil


-- 月火术、虫群监测
local MoonfireCheck = {}
local MoonfireDelayTime = {}
local DruidMoonfireDuration = 18

local InsectSwarmCheck = {}
local InsectSwarmDelayTime = {}
local DruidInsectSwarmDuration = 18

-- 续杯
local RefillTimer = 0
local RefillGUID = 0
local Refill = false
local RefillMiss = 0

local ComboPoints = 0



local function ResetData()

    RateCheck = {}
    RateDelayTime = {}
    RipCheck = {}
    RipDelayTime = {}
    RavageCheck = {}
    RavageDelayTime = {}

    MoonfireCheck = {}
    MoonfireDelayTime = {}

    InsectSwarmCheck = {}
    InsectSwarmDelayTime = {}

    RefillTimer = 0
    RefillGUID = 0
    Refill = false
    RefillMiss = 0

end

local function OnEvent()

    -- 进入战斗事件
    if event == "PLAYER_REGEN_DISABLED" then


    -- 离开战斗事件
    elseif event == "PLAYER_REGEN_ENABLED" then
        ResetData()

    -- 玩家死亡，重置一些参数
    elseif event == "PLAYER_DEAD" then
        ResetData()


    elseif event == "PLAYER_COMBO_POINTS" then

        if Cat2.SuperWoW then

            if Refill then
                if RateCheck[RefillGUID] and GetTime()-RateCheck[RefillGUID]<DruidRakeDuration then RateCheck[RefillGUID]=RefillTimer end
                if RipCheck[RefillGUID] and GetTime()-RipCheck[RefillGUID]<DruidRipDuration then RipCheck[RefillGUID]=RefillTimer end
                Refill = false
            end

        end

    -- 回能量事件处理
    elseif event == "UNIT_ENERGY" and arg1 == "player" then
        local maximumEnergy = UnitManaMax("player")
        local currentEnergy = UnitMana("player")

        -- 防止非能量
        if maximumEnergy<150 then

            -- 第一份数据只建立快照；后续事件再比较实际能量变化。
            if OldEnergy ~= nil then
                local energyChange = currentEnergy-OldEnergy
                if energyChange==20 then

                    -- 捕获一次真实自然回能，并以此校准后续2秒周期。
                    RestoredEnergyTime = GetTime()
                end
            end

            -- UNIT_ENERGY 独立维护前一次能量快照。
            OldEnergy = currentEnergy
        end

    ---------------------------
    -- SuperWoW事件 -----------
    ---------------------------

    -- 施法、攻击事件处理
    elseif event == "UNIT_CASTEVENT" then

        if arg3 == "CAST" then

            -- 仅监控自己放出的技能
            if arg1 == Cat2.PlayerInformation.basic.guid then

                --print(arg4)

                -- 监控双流血
                -- 扫击
                if arg4 == 9904 then

                    RateDelayTime[arg2] = GetTime()
                    DruidRateJumpTimer = GetTime() + 3.0

                -- 撕扯
                elseif arg4 == 9896 then

                    RipDelayTime[arg2] = GetTime()
                    -- 动态调整持续时间
                    DruidRipDuration = 8+ComboPoints*2

                    DruidRipJumpTimer = GetTime() + 2.0

                -- 血袭
                elseif arg4 == 9827 then
                    RavageDelayTime[arg2] = GetTime()

                -- 监控月火术、虫群
                -- 月火术
                elseif arg4==8921 or arg4==8924 or arg4==8925 or arg4==8926 or arg4==8927 or arg4==8928 or arg4==8929 or arg4==9833 or arg4==9834 or arg4==9835 then
                    MoonfireDelayTime[arg2] = GetTime()
                -- 虫群
                elseif arg4==5570 or arg4==24974 or arg4==24975 or arg4==24976 or arg4==24977 then
                    InsectSwarmDelayTime[arg2] = GetTime()

                -- 凶猛撕咬 31018
                elseif arg4 == 31018 then 

                    -- 续杯机制
                    Refill = true
                    RefillTimer = GetTime()
                    RefillGUID = arg2

                -- 重整
                elseif arg4 == 768 then
                    Cat2.DruidMHTimer = 0

                elseif arg4 == 9634 then
                    Cat2.DruidMHTimer = 0

                -- 猛虎之怒
                elseif arg4 == 9846 then
                    Cat2.DruidMHTimer = GetTime()
                    DruidTigerFuryTimer = GetTime() + 3.0
                
                end

            end

        end

    -- 战斗日志事件处理
    elseif event == "RAW_COMBATLOG" then

        -- 自己的攻击
        if arg1 == "CHAT_MSG_SPELL_SELF_DAMAGE" then

            -- 扫击
            if string.find( arg2, "你的扫击.*招架.*" ) or string.find( arg2, "你的扫击.*躲闪.*" ) or string.find( arg2, "你的扫击.*格挡.*" ) or string.find( arg2, "你的扫击.*没有击中.*" ) or ( string.find(arg2 or "", Cat2.L.Spell("扫击")) and ( string.find(arg2 or "", "dodg") or string.find(arg2 or "", "parr") or string.find(arg2 or "", "block") or string.find(arg2 or "", "miss") ) ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and RateDelayTime[targetGUID] then 
                    local timer = GetTime() - RateDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        RateDelayTime[targetGUID] = nil
                    end
                end

            -- 撕扯
            elseif string.find( arg2, "你的撕扯.*招架.*" ) or string.find( arg2, "你的撕扯.*躲闪.*" ) or string.find( arg2, "你的撕扯.*格挡.*" ) or string.find( arg2, "你的撕扯.*没有击中.*" ) or ( string.find(arg2 or "", Cat2.L.Spell("撕扯")) and ( string.find(arg2 or "", "dodg") or string.find(arg2 or "", "parr") or string.find(arg2 or "", "block") or string.find(arg2 or "", "miss") ) ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and RipDelayTime[targetGUID] then 
                    local timer = GetTime() - RipDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        RipDelayTime[targetGUID] = nil
                    end
                end

            elseif string.find( arg2, "你的凶猛撕咬.*招架.*" ) or string.find( arg2, "你的凶猛撕咬.*躲闪.*" ) or string.find( arg2, "你的凶猛撕咬.*格挡.*" ) or string.find( arg2, "你的凶猛撕咬.*没有击中.*" ) or ( string.find(arg2 or "", Cat2.L.Spell("凶猛撕咬")) and ( string.find(arg2 or "", "dodg") or string.find(arg2 or "", "parr") or string.find(arg2 or "", "block") or string.find(arg2 or "", "miss") ) ) then
                Refill = false
                RefillGUID = 0
                RefillTimer = 0

            -- 月火术
            elseif string.find( arg2, "你的月火术被.*抵抗.*" ) or string.find( arg2 or "", Cat2.L.Spell("月火术") .. " was resisted" ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and MoonfireDelayTime[targetGUID] then 
                    local timer = GetTime() - MoonfireDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        MoonfireDelayTime[targetGUID] = nil
                    end
                end

            -- 虫群
            elseif string.find( arg2, "你的虫群被.*抵抗.*" ) or string.find( arg2 or "", Cat2.L.Spell("虫群") .. " was resisted" ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and InsectSwarmDelayTime[targetGUID] then 
                    local timer = GetTime() - InsectSwarmDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        InsectSwarmDelayTime[targetGUID] = nil
                    end
                end

            end

        elseif arg1 == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" then

            -- 扫击 dot jump
            if string.find( arg2, "你的扫击使.*" ) then
                DruidRateJumpTimer = GetTime() + 3.0

            -- 撕扯 dot jump
            elseif string.find( arg2, "你的撕扯使.*" ) then
                DruidRipJumpTimer = GetTime() + 2.0

            end

        elseif arg1 == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" then

            if string.find( arg2, "你从猛虎之怒.*" ) then
                DruidTigerFuryTimer = GetTime() + 3.0
            end

        end

    end

end


local function OnUpdate()

    -- 保存Combo
    -- 注意：这如果放在事件中，特别是终结技的事件中，星已经被清空
    ComboPoints = GetComboPoints()


    if Cat2.SuperWoW then

        if Refill then
            local time = GetTime() - RefillTimer
            if time>0.4 then
                Refill = false
            end
        end

    end

end


-- 设置事件处理函数
frame:SetScript("OnEvent", OnEvent)
frame:SetScript("OnUpdate", OnUpdate)


-- 获取当前回能时间（猫德使用）
-- 注：双流血猫德不建议使用
-- return 首次捕获自然回能前返回 nil；捕获后返回当前2秒回能周期中的位置
function Cat2.DruidRestoredEnergy()
    -- 尚未捕获真实自然回能时，不提供推算结果。
    if RestoredEnergyTime == nil then
        return nil
    end

    local timer = GetTime()-RestoredEnergyTime
    if timer<0 then
        return nil
    end

    local fullCycles = math.floor(timer / 2)  -- 完整的2秒周期数
    local cyclePos = timer - (fullCycles * 2)  -- 当前周期中的位置
    return cyclePos
end



---------事件计算部分------------------------------------

-- 获取当前目标是否有扫击效果
-- 注：SuperWow支持更加准确
-- return 存在返回真

local function GetRakeDotCheck( guid, value )
    if RateCheck[guid] then
        local timer = GetTime() - RateCheck[guid]
        if timer <= (DruidRakeDuration-value) then
            return true
        else
            RateCheck[guid] = nil
        end
    end

    return false
end

function Cat2.ResetRakeDot(guid)
    RateCheck[guid] = nil
end

function Cat2.GetRakeDot(unit, value)
    unit = unit or "target"
    value = value or 0


    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["扫击"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists(unit)
    if not guid then
        return false
    end

    -- 0.2秒监测期里
    if RateDelayTime[guid] then 
        local timer = GetTime() - RateDelayTime[guid]
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            RateCheck[guid] = RateDelayTime[guid]
            RateDelayTime[guid] = nil
        end
    end

    return GetRakeDotCheck(guid, value)
end



-- 获取当前目标是否有撕扯效果
-- 注：SuperWow支持更加准确
-- return 存在返回真

local function GetRipDotCheck( guid, value )
    if RipCheck[guid] then
        local timer = GetTime() - RipCheck[guid]
        if timer < (DruidRipDuration-value) then
            return true
        else
            RipCheck[guid] = nil
        end
    end

    return false
end

function Cat2.ResetRipDot(guid)
    RipCheck[guid] = nil
end

function Cat2.GetRipDot(unit, value)
    unit = unit or "target"
    value = value or 0

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["撕扯"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists(unit)
    if not guid then
        return false
    end

    -- 0.2秒监测期里
    if RipDelayTime[guid] then 
        local timer = GetTime() - RipDelayTime[guid]
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            RipCheck[guid] = RipDelayTime[guid]
            RipDelayTime[guid] = nil
        end
    end

    return GetRipDotCheck(guid, value)
end



-- 获取当前目标是否有血袭效果
-- 注：SuperWow支持更加准确
-- return 存在返回真

local function GetRavageDotCheck( guid, value )
    if RavageCheck[guid] then
        local timer = GetTime() - RavageCheck[guid]
        if timer < (DruidRavageDuration-value) then
            return true
        else
            RavageCheck[guid] = nil
        end
    end

    return false
end

function Cat2.GetRavageDot(unit, value)
    unit = unit or "target"
    value = value or 0

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["血袭"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists(unit)
    if not guid then
        return false
    end

    -- 0.2秒监测期里
    if RavageDelayTime[guid] then 
        local timer = GetTime() - RavageDelayTime[guid]
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            RavageCheck[guid] = RavageDelayTime[guid]
            RavageDelayTime[guid] = nil
        end
    end

    return GetRavageDotCheck(guid, value)
end





-- 获取当前目标是否有月火术效果
-- 注：SuperWow支持更加准确
-- return 存在返回真

local function GetMoonfireDotCheck( guid )
    if MoonfireCheck[guid] then
        local timer = GetTime() - MoonfireCheck[guid]
        if timer < DruidMoonfireDuration then
            return true
        else
            MoonfireCheck[guid] = nil
        end
    end

    return false
end

function Cat2.GetMoonfireDot(unit)

    unit = unit or "target"

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["月火术"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists(unit)
    if not guid then
        return false
    end

    -- 0.2秒监测期里
    if MoonfireDelayTime[guid] then 
        local timer = GetTime() - MoonfireDelayTime[guid]
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true 
        else
            -- 已经过了认证期
            MoonfireCheck[guid] = MoonfireDelayTime[guid]
            MoonfireDelayTime[guid] = nil
        end
    end

    return GetMoonfireDotCheck(guid)
end


-- 获取当前目标是否有虫群效果
-- 注：SuperWow支持更加准确
-- return 存在返回真

local function GetInsectSwarmDotCheck( guid )
    if InsectSwarmCheck[guid] then
        local timer = GetTime() - InsectSwarmCheck[guid]
        if timer < DruidInsectSwarmDuration then
            return true
        else
            InsectSwarmCheck[guid] = nil
        end
    end

    return false
end

function Cat2.GetInsectSwarmDot(unit)

    unit = unit or "target"

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["虫群"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists(unit)
    if not guid then
        return false
    end

    -- 0.2秒监测期里
    if InsectSwarmDelayTime[guid] then 
        local timer = GetTime() - InsectSwarmDelayTime[guid]
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            InsectSwarmCheck[guid] = InsectSwarmDelayTime[guid]
            InsectSwarmDelayTime[guid] = nil
        end
    end

    return GetInsectSwarmDotCheck(guid)
end



