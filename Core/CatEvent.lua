-- Cat2 客户端事件与扩展能力探测。
-- 登录时探测 UnitXP、SuperWoW、Nampower、Interact 等乌龟服扩展，并维护自动攻击相关状态。
-- 本文件保留历史兼容变量；新增功能应优先写入 Cat2 命名空间，避免继续扩大旧全局变量范围。
-- 创建一个 Frame 并监听事件。
local frame = CreateFrame("Frame")

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_ENTER_COMBAT")
frame:RegisterEvent("PLAYER_LEAVE_COMBAT")

frame:RegisterEvent("SPELLCAST_START")
frame:RegisterEvent("SPELLCAST_STOP")
frame:RegisterEvent("SPELLCAST_FAILED")
frame:RegisterEvent("SPELLCAST_INTERRUPTED")

frame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")

frame:RegisterEvent("UI_ERROR_MESSAGE")

-- SuperWow专有事件
frame:RegisterEvent("UNIT_CASTEVENT")
frame:RegisterEvent("RAW_COMBATLOG")


-- 模组参数
Cat2.UnitXP = pcall(UnitXP, "nop", "nop");
Cat2.SuperWoW = false
Cat2.SuperWoWVersion = 0
Cat2.Nampower = false
Cat2.Nampower3 = false
Cat2.Nampower4 = false
Cat2.Nampower5 = false
Cat2.Interact = false


-- 是否能打背标记变量
local ErrorBehind = true
local ErrorBehindTimer = 0

-- GCD计时器
local gcdtimer = 0
local gcdmax = 1.5
-- 自己读条计时
local isCast = false

-- 普攻计时器(主手)
local MainHandBeginTime = 0
local MainHandDuration = 0

-- 是否正在施法计时器，用于打断
local castStartTime = {}
local castName = {}
local castDuration = {}


local function BeginHit()
    -- 记录挥击开始时间
    MainHandBeginTime = GetTime()
    -- 记录挥击时的普攻总时长
    MainHandDuration = UnitAttackSpeed("player")
end

function Cat2.GetIsCast()
    return isCast
end

local function ResetData()
    isCast = false
    castStartTime = {}
    castName = {}
    castDuration = {}
    Cat2.AutoAttack = false
    Cat2.AutoAttackLock = false
end


-- 周围的guid收集容器
local ObjectArray = {}

function Cat2.PushObject(inGUID)

    if inGUID and not ObjectArray[inGUID] then
        if UnitCanAttack("player", inGUID) and not UnitIsDead(inGUID) then
            ObjectArray[inGUID] = GetTime()
        end
    end

end

local function CheckSpellLog(str)

    if not str then
        return
    end

    -- 通过日志收集周围目标
    local objectGUID = Cat2.MatchGUID(str) 

    if objectGUID and UnitCanAttack("player", objectGUID) then
        -- 打断部分收集信息
        local spellName = Cat2.Match(str, "开始施放(.-)。")
        if spellName then
            castStartTime[objectGUID] = GetTime()
            castName[objectGUID] = spellName
            castDuration[objectGUID] = 20000        -- 用20秒作为长度
            --MPMsg("敌方 ["..objectGUID.."] 开始施放 ["..spellName.."]")
            return
        end
    end

end

local function CheckCombatLog(str)

    -- 通过日志收集周围目标
    local objectGUID = Cat2.MatchGUID(str) 
    Cat2.PushObject(objectGUID)

end



local function OnEvent()

    -- 初始化
    if event == "PLAYER_LOGIN" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF9264cdCat2 加载完成！|r")

        if SUPERWOW_STRING then
            Cat2.SuperWoW = true
        end

        if type(GetNampowerVersion) == "function" then
            Cat2.Nampower = true
        end

        -- 检测Interact
        local secc = false
        if type(InteractNearest) == "function" then
            secc = true
        end
        if not secc then
            secc = pcall(function()
                UnitXP("interact", 1)
            end)
        end
        Cat2.Interact = secc

        if Cat2.Nampower then
            local major, minor, patch=GetNampowerVersion()
            if major>=4 then
                Cat2.Nampower4 = true
		        SetCVar("NP_EnableAutoAttackEvents", "1") 
		        SetCVar("NP_EnableAuraCastEvents", "1") 
		        SetCVar("NP_EnableSpellHealEvents", "1") 
		        SetCVar("NP_EnableSpellGoEvents", "1")
		        SetCVar("NP_EnableSpellStartEvents", "1")
            end
            if major==3 then
                Cat2.Nampower3 = true
            end

        end

    elseif event == "ADDON_LOADED" then

        if arg1 == "Cat2" then

            Cat2.RefreshPlayerBasicInformation()

        end

    -- 进入游戏世界刷新常量值
    elseif event == "PLAYER_ENTERING_WORLD" then

        Cat2.RefreshPlayerBasicInformation()
        frame:UnregisterEvent("PLAYER_ENTERING_WORLD")


    -- 开启自动攻击的状态处理，未必进入战斗
    elseif event == "PLAYER_ENTER_COMBAT" then
        Cat2.AutoAttack = true

    elseif event == "PLAYER_LEAVE_COMBAT" then
        Cat2.AutoAttack = false

    -- 背面判断
    elseif event == "UI_ERROR_MESSAGE" then
        if arg1=="你必须位于目标背后" then
            ErrorBehindTimer = GetTime()
            ErrorBehind = false
        end


    -- 施法事件处理，读条类，读条也要处理GCD
    elseif event == "SPELLCAST_START" then
        -- GCD时间处理
        isCast = true
        gcdtimer = GetTime()
        gcdmax = 1.5

        if Cat2.PlayerInformation.basic.classFile=="DRUID" then
            if Cat2.PlayerInformation.temporary.buff["猎豹形态"] then
                gcdmax = 1.0
            end
        elseif Cat2.PlayerInformation.basic.classFile=="ROGUE" then
            gcdmax = 1.0
        end

    elseif event == "SPELLCAST_STOP" then
        -- GCD时间处理
        if isCast then
            isCast = false
        else

            -- 未读条，应该是瞬发，GCD时间启动
            gcdtimer = GetTime()
            gcdmax = 1.5

            if Cat2.PlayerInformation.basic.classFile=="DRUID" then
                if Cat2.PlayerInformation.temporary.buff["猎豹形态"] then
                    gcdmax = 1.0
                end
            elseif Cat2.PlayerInformation.basic.classFile=="ROGUE" then
                gcdmax = 1.0
            end

        end

    elseif event == "SPELLCAST_FAILED" then
        -- GCD时间处理
        if isCast then
            isCast = false
        end

    elseif event == "SPELLCAST_INTERRUPTED" then
        -- GCD时间处理
        if isCast then
            isCast = false
        end

    -- 技能伤害
    elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then

        if string.find( arg1, "你的英勇打击.*" ) then
            BeginHit()
        elseif string.find( arg1, "你的顺劈斩.*" ) then
            BeginHit()
        end

    -- 躲避miss等
    elseif event == "CHAT_MSG_COMBAT_SELF_MISSES" then

        if not Cat2.SuperWoW then
            if string.find( arg1, "你发起了攻击.*" ) then
                BeginHit()
            elseif string.find( arg1, "你没有击中.*" ) then
                BeginHit()
            end
        end

    elseif event == "CHAT_MSG_COMBAT_SELF_HITS" then

        if not Cat2.SuperWoW then
            if string.find( arg1, "你对.*" ) then
                BeginHit()
            elseif string.find( arg1, "你击中.*" ) then
                BeginHit()
            end
        end



    ---------------------------
    -- SuperWoW事件 -----------
    ---------------------------

    -- 施法、攻击事件处理
    elseif event == "UNIT_CASTEVENT" then

        Cat2.PushObject(arg1)
        Cat2.PushObject(arg2)
        
        -- 施法事件监测
        if arg3 == "START" then

            if arg1 == Cat2.PlayerInformation.basic.guid then
                isCast = true
            end

        elseif arg3 == "CAST" then

            -- 监控所有人

            -- 用于打断，清空该读条
            if castStartTime[arg1] then 
                castStartTime[arg1] = nil
                castName[arg1] = nil
                castDuration[arg1] = nil
            end

            -- 仅监控自己放出的技能
            if arg1 == Cat2.PlayerInformation.basic.guid then
                isCast = false
            end


        elseif arg3 == "FAIL"  then
            if arg1 == Cat2.PlayerInformation.basic.guid then
                isCast = false
            end

            -- 用于打断，清空该读条
            if castStartTime[arg1] then
                castStartTime[arg1] = nil
                castName[arg1] = nil
                castDuration[arg1] = nil
            end

        elseif arg3 == "MAINHAND" then

            if arg1==Cat2.PlayerInformation.basic.guid then
                BeginHit()
            end

        end


    -- 战斗日志事件处理
    elseif event == "RAW_COMBATLOG" then

        -- 用于收集读条的技能名字，而不是ID
        CheckSpellLog(arg2)

    end
end


local interval = 0.05  -- 轮询间隔（秒）
local elapsed = 0
local nameframe_interval = 0.2  -- 轮询间隔（秒）
local nameframe_elapsed = 0

local prevX, prevY = 0, 0
-- 角色移动状态（全局）
Cat2.PlayerIsMoving = false

local function NameFramePollingFunction()

    if not Cat2.SuperWoW then
        return
    end

    -- 收集NamePlate
    local parentcount = WorldFrame:GetNumChildren()
    local childs = { WorldFrame:GetChildren() }
	for i=1, parentcount do
		plate = childs[i]
		if plate:GetObjectType() ~= NAMEPLATE_FRAMETYPE then 
            if plate:GetName(1) then
                Cat2.PushObject(plate:GetName(1))
			end
		end
	end

end

local function OnUpdate()
    -- 处理自动攻击
    elapsed = elapsed + arg1
    if elapsed >= interval then
        elapsed = 0  -- 重置计时器
        if Cat2.AutoAttackLock then
            if GetTime()-Cat2.AutoAttackLockTimer > 0.2 then
                Cat2.AutoAttackLock = false
            end
        end
    end


    nameframe_elapsed = nameframe_elapsed + arg1
    if nameframe_elapsed >= nameframe_interval then
        nameframe_elapsed = 0  -- 重置计时器
        NameFramePollingFunction()
    end


    -- 计算角色是否在移动
    if not Cat2.Nampower3 then
        local x, y = GetPlayerMapPosition("player")
        if x ~= prevX or y ~= prevY then
            if not Cat2.PlayerIsMoving then
                Cat2.PlayerIsMoving = true
            end
        else
            if Cat2.PlayerIsMoving then
                Cat2.PlayerIsMoving = false
            end
        end
        prevX, prevY = x, y
    end

end


-- 设置事件处理函数
frame:SetScript("OnEvent", OnEvent)
frame:SetScript("OnUpdate", OnUpdate)







-- 获取普攻剩余时间（主手）
-- return 返回下一次攻击的剩余时间
function Cat2.GetMainHandLeft()
    local t = GetTime() - MainHandBeginTime
    local left = MainHandDuration - t;

    if left < 0 then
        return 0
    end

    return left
end

-- 获取普攻消耗掉的时间（主手）
function Cat2.GetMainHandTime()
    return GetTime() - MainHandBeginTime
end


-- 获取目标是否正在施法
-- 注：需要SuperWow支持
-- return 成立返回真,返回法术ID
function Cat2.TargetCast()

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW then
        return false, 0
    end

    -- 获取目标GUID，并确保其存在
    local _,guid=UnitExists("target")
    if not guid then
        return false, 0
    end

    if castStartTime[guid] ~= nil then
        if castName[guid] then
            local timer = GetTime()-castStartTime[guid]
            if timer < castDuration[guid] then
                return true, castName[guid]
            else
                return false, 0
            end
        end
        
        return true, 0
    end

    return false, 0
end


--------------------------------------------
-- 公共冷却时间 GCD
--------------------------------------------

-- 获取当前技能GCD
-- 适用于瞬发技能，读条技能不适用
-- return 0-1.5 有效范围，超出则GCD已经完成
function Cat2.GetGCD()
    return GetTime()-gcdtimer
end

-- 获取当前技能GCD的剩余时间
function Cat2.GetLeftGCD()
    if Cat2.GetGCD() < Cat2.GCDMax() then
        return Cat2.GCDMax()-Cat2.GetGCD()
    end

    return 0
end

-- 获取当前技能GCD的时长，如：1.5秒 1.0秒
function Cat2.GCDMax()
    return gcdmax
end



--------------------------------------------
-- 目标的朝向
--------------------------------------------


-- 获取目标的朝向
-- return 获取成立返回真
function Cat2.CheckBehind()

    -- 检测异常捕获的方向错误
    if ErrorBehind == false then
        if GetTime() - ErrorBehindTimer > 0.3 then
            ErrorBehind = true
        else
            return false
        end
    end

    if Cat2.UnitXP then
        return UnitXP("behind", "player", "target")
    end

    return true
end



--------------------------------------------
-- 搜索身边的敌人数量
--------------------------------------------


-- return 敌人数量
local NearEmeny = 0
local NearEmenyList = {}
local EmenyList = {}
local MaxCount = 0


function Cat2.ScanNearbyEnemies(range)

    range = range or 5;

    -- 未安装SuperWoW
    if not Cat2.SuperWoW then
        return 0,0
    end

    local count = 0
    local inMeleeRange
    local _,targetGUID = UnitExists("target")  -- 保存当前目标GUID
    local toRemove = {}  -- 存储待删除的键

    MaxCount = 0
    NearEmeny = 0
    NearEmenyList = {}
    EmenyList = {}

    -- 检查自己的目标
    if targetGUID then
        Cat2.PushObject(targetGUID)
    end

    if not Cat2.PlayerInformation.temporary.inCombat then
        -- 检查团队成员（1-40），仅在团队中时生效
        if GetNumRaidMembers() > 0 then  -- 替代 IsInRaid()
            for i = 1, 40 do
                local unit = "raid" .. i
                if UnitExists(unit) then
                    local targetUnit = unit .. "target"
                    local r, raidtargetGUID = UnitExists(targetUnit)
                    if r then
                        Cat2.PushObject(raidtargetGUID)
                    end
                end
            end
        elseif GetNumPartyMembers() > 0 then
            -- 检查小队成员（1-4）
            for i = 1, 4 do
                local unit = "party" .. i
                if UnitExists(unit) then
                    local targetUnit = unit .. "target"
                    local p, partytargetGUID = UnitExists(targetUnit)
                    if p then
                        Cat2.PushObject(partytargetGUID)
                    end
                end
            end
        end
    end



    -- 基础部分

    for key, value in pairs(ObjectArray) do
        if GetTime()-value < 120 then
            local t = UnitExists(key)
            if t then
                if UnitCanAttack("player", key) and not UnitIsDead(key) then        -- 这里不能去掉，目标状态可能会变化 
                    EmenyList[key] = true
                    -- 是否在近战距离
                    if Cat2.UnitXP then
                        inMeleeRange = UnitXP("distanceBetween", "player", key)
                        if inMeleeRange and inMeleeRange<range then
                            NearEmeny = NearEmeny + 1
                            NearEmenyList[key] = true
                        end
                    else
                        inMeleeRange = CheckInteractDistance(key, 3)
                        if inMeleeRange then
                            NearEmeny = NearEmeny + 1
                            NearEmenyList[key] = true
                        end
                    end
                else
                    table.insert(toRemove, key)
                end
            else
                table.insert(toRemove, key)
            end

        else
            table.insert(toRemove, key)
        end

        MaxCount = MaxCount + 1
    end

    -- 循环结束后统一删除
    for _, k in ipairs(toRemove) do
        ObjectArray[k] = nil
    end

    return NearEmeny,MaxCount,NearEmenyList,EmenyList
end



-- 获取目标与自己是否在近战距离
-- return 真/否
function Cat2.TargetDistance(unit,range)

    unit = unit or "target";
    -- 对象检测
    if not UnitExists(unit) then
        return false
    end

    range = range or 5
    local inMeleeRange = 0

    -- 是否在近战距离
    if Cat2.UnitXP then
        if range>5 then
            inMeleeRange = UnitXP("distanceBetween", "player", unit)
            if not inMeleeRange then
                return false
            end
        else
            inMeleeRange = UnitXP("distanceBetween", "player", unit, "meleeAutoAttack")
            if not inMeleeRange then
                return false
            end
        end
        --print(inMeleeRange)
        --print(range)
        if inMeleeRange>range then
            return false
        end
    else

        -- 判断近战距离
        if range < 3.0 then
            inMeleeRange = CheckInteractDistance(unit, 3)
            if inMeleeRange then
                return true
            else
                return false
            end
        end
    end

    return true
end

