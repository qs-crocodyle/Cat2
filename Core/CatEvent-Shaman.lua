local _, playerClass = UnitClass("player")
if playerClass ~= "SHAMAN" then
    return  -- 终止文件执行
end

-- 创建一个 Frame 并监听事件
local frame = CreateFrame("Frame")

frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
frame:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH")
frame:RegisterEvent("SPELLCAST_START")
frame:RegisterEvent("SPELLCAST_STOP")
frame:RegisterEvent("SPELLCAST_FAILED")
frame:RegisterEvent("SPELLCAST_INTERRUPTED")

-- SuperWow专有事件
frame:RegisterEvent("UNIT_CASTEVENT")
frame:RegisterEvent("RAW_COMBATLOG")


-- 烈焰震击
local FlameShockCheck = {}
local FlameShockDelayTime = {}

-- 火震 持续时间
local ShamanFlameShockDuration = 15
-- 熔岩爆裂 读条
local BeginLavaBurstCastTimer = 0


local EarthTotemTimer = 0
local EarthTotemDuration = 0
local EarthTotemName = ""
local EarthTotemX = 0
local EarthTotemY = 0

local FireTotemTimer = 0
local FireTotemDuration = 0
local FireTotemName = ""
local FireTotemX = 0
local FireTotemY = 0

local WaterTotemTimer = 0
local WaterTotemDuration = 0
local WaterTotemName = ""
local WaterTotemX = 0
local WaterTotemY = 0

local AirTotemTimer = 0
local AirTotemDuration = 0
local AirTotemName = ""
local AirTotemX = 0
local AirTotemY = 0

-- 等待技能反馈的等待时间
local BLEENCHECKDELAY = 0.2

local function ResetData()
    FlameShockCheck = {}
    FlameShockDelayTime = {}
    BeginLavaBurstCastTimer = 0
end

local function OnEvent()

    if event == "PLAYER_REGEN_ENABLED" then

        ResetData()

    -- 玩家死亡，重置参数
    elseif event == "PLAYER_DEAD" then

        ResetData()

        EarthTotemTimer = 0
        EarthTotemDuration = 0
        EarthTotemName = ""
        EarthTotemX = 0
        EarthTotemY = 0

        FireTotemTimer = 0
        FireTotemDuration = 0
        FireTotemName = ""
        FireTotemX = 0
        FireTotemY = 0

        WaterTotemTimer = 0
        WaterTotemDuration = 0
        WaterTotemName = ""
        WaterTotemX = 0
        WaterTotemY = 0

        AirTotemTimer = 0
        AirTotemDuration = 0
        AirTotemName = ""
        AirTotemX = 0
        AirTotemY = 0

    -- 施法事件处理，读条类，读条也要处理GCD
    elseif event == "SPELLCAST_START" then

        if arg1 == "熔岩爆裂" then 
            BeginLavaBurstCastTimer = GetTime()+4.0
        end

    elseif event == "SPELLCAST_STOP" then


    elseif event == "SPELLCAST_FAILED" then

        BeginLavaBurstCastTimer = GetTime()

    elseif event == "SPELLCAST_INTERRUPTED" then

        BeginLavaBurstCastTimer = GetTime()

    -- 捕获图腾消失
    elseif event == "CHAT_MSG_COMBAT_FRIENDLY_DEATH" then

        if string.find( arg1, ".*根基图腾.*" ) then
            if Cat2.SuperWoW then
                local mainplayer = Cat2.Match(arg1, "%((.-)%)")
                if mainplayer == UnitName("player") then
                    AirTotemTimer = 0
                end
            else
                AirTotemTimer = 0
            end
        end

    elseif event == "CHAT_MSG_SPELL_SELF_BUFF" then

        if string.find( arg1, ".*图腾召回.*" ) then
            EarthTotemTimer = 0
            FireTotemTimer = 0
            WaterTotemTimer = 0
            AirTotemTimer = 0
        end

        if not Cat2.SuperWoW then
            local totemName = Cat2.Match(arg1, "你施放了(.+)。")

            if totemName=="地缚图腾" then
                EarthTotemDuration = 45
                EarthTotemTimer = GetTime()
                EarthTotemName = "地缚图腾"
            elseif totemName=="石爪图腾" then
                EarthTotemDuration = 15
                EarthTotemTimer = GetTime()
                EarthTotemName = "石爪图腾"
            elseif totemName=="大地之力图腾" then
                EarthTotemDuration = 120
                EarthTotemTimer = GetTime()
                EarthTotemName = "大地之力图腾"
            elseif totemName=="石肤图腾" then
                EarthTotemDuration = 120
                EarthTotemTimer = GetTime()
                EarthTotemName = "石肤图腾"
            elseif totemName=="战栗图腾" then
                EarthTotemDuration = 120
                EarthTotemTimer = GetTime()
                EarthTotemName = "战栗图腾"

            elseif totemName=="火焰新星图腾" then
                FireTotemDuration = 5
                FireTotemTimer = GetTime()
                FireTotemName = "火焰新星图腾"

            elseif totemName=="灼热图腾" then
                FireTotemDuration = 55
                FireTotemTimer = GetTime()
                FireTotemName = "灼热图腾"

            elseif totemName=="熔岩图腾" then
                FireTotemDuration = 20
                FireTotemTimer = GetTime()
                FireTotemName = "熔岩图腾"

            elseif totemName=="抗寒图腾" then
                FireTotemDuration = 120
                FireTotemTimer = GetTime()
                FireTotemName = "抗寒图腾"

            elseif totemName=="火舌图腾" then
                FireTotemDuration = 120
                FireTotemTimer = GetTime()
                FireTotemName = "火舌图腾"

            elseif totemName=="抗火图腾" then
                WaterTotemDuration = 120
                WaterTotemTimer = GetTime()
                WaterTotemName = "抗火图腾"

            elseif totemName=="治疗之泉图腾" then
                WaterTotemDuration = 60
                WaterTotemTimer = GetTime()
                WaterTotemName = "治疗之泉图腾"

            elseif totemName=="法力之泉图腾" then
                WaterTotemDuration = 60
                WaterTotemTimer = GetTime()
                WaterTotemName = "法力之泉图腾"

            elseif totemName=="清毒图腾" then
                WaterTotemDuration = 120
                WaterTotemTimer = GetTime()
                WaterTotemName = "清毒图腾"

            elseif totemName=="祛病图腾" then
                WaterTotemDuration = 120
                WaterTotemTimer = GetTime()
                WaterTotemName = "祛病图腾"

            elseif totemName=="岗哨图腾" then
                AirTotemDuration = 300
                AirTotemTimer = GetTime()
                AirTotemName = "岗哨图腾"

            elseif totemName=="根基图腾" then
                AirTotemDuration = 45
                AirTotemTimer = GetTime()
                AirTotemName = "根基图腾"

            elseif totemName=="自然抗性图腾" then
                AirTotemDuration = 120
                AirTotemTimer = GetTime()
                AirTotemName = "自然抗性图腾"

            elseif totemName=="风之优雅图腾" then
                AirTotemDuration = 120
                AirTotemTimer = GetTime()
                AirTotemName = "风之优雅图腾"

            elseif totemName=="风墙图腾" then
                AirTotemDuration = 120
                AirTotemTimer = GetTime()
                AirTotemName = "风墙图腾"

            elseif totemName=="风怒图腾" then
                AirTotemDuration = 120
                AirTotemTimer = GetTime()
                AirTotemName = "风怒图腾"

            elseif totemName=="宁静之风图腾" then
                AirTotemDuration = 120
                AirTotemTimer = GetTime()
                AirTotemName = "宁静之风图腾"

            end

        end


    ---------------------------
    -- SuperWoW事件 -----------
    ---------------------------

    -- 施法、攻击事件处理
    elseif event == "UNIT_CASTEVENT" then

        if arg3 == "CAST" then

            if arg1 == Cat2.PlayerInformation.basic.guid then
                
                -- 图腾召回
                if arg4 == 45513 then
                    EarthTotemTimer = 0
                    FireTotemTimer = 0
                    WaterTotemTimer = 0
                    AirTotemTimer = 0


                ----------------
                -- 大地图腾
                ----------------

                -- 地缚图腾
                elseif arg4 == 2484 then
                    EarthTotemDuration = 45
                    EarthTotemTimer = GetTime()
                    EarthTotemName = "地缚图腾"

                -- 石爪图腾
                elseif arg4 == 5730 or arg4==6390 or arg4==6391 or arg4==6392 or arg4==10427 or arg4==10428 then
                    EarthTotemDuration = 15
                    EarthTotemTimer = GetTime()
                    EarthTotemName = "石爪图腾"

                -- 大地之力图腾
                elseif arg4 == 8075 or arg4==8160 or arg4==8161 or arg4==10442 or arg4==25361 then
                    EarthTotemDuration = 120
                    EarthTotemTimer = GetTime()
                    EarthTotemName = "大地之力图腾"

                -- 石肤图腾
                elseif arg4 == 8071 or arg4==8154 or arg4==8155 or arg4==10406 or arg4==10407 or arg4==10408 then
                    EarthTotemDuration = 120
                    EarthTotemTimer = GetTime()
                    EarthTotemName = "石肤图腾"

                -- 战栗图腾
                elseif arg4 == 8143 then
                    EarthTotemDuration = 120
                    EarthTotemTimer = GetTime()
                    EarthTotemName = "战栗图腾"

                ----------------
                -- 火焰图腾
                ----------------

                -- 火焰新星图腾
                elseif arg4==1535 or arg4==8498 or arg4==8499 or arg4==11314 or arg4==11315 then
                    FireTotemDuration = 5
                    FireTotemTimer = GetTime()
                    FireTotemName = "火焰新星图腾"

                -- 灼热图腾
                elseif arg4==3599 then-- arg4==6363 or arg4==6364 or arg4==6365 or arg4==10437 or arg4==10438 then
                    FireTotemDuration = 30
                    FireTotemTimer = GetTime()
                    FireTotemName = "灼热图腾"

                elseif arg4==6363 then--  arg4==6364 or arg4==6365 or arg4==10437 or arg4==10438 then
                    FireTotemDuration = 35
                    FireTotemTimer = GetTime()
                    FireTotemName = "灼热图腾"

                elseif arg4==6364 then--   arg4==6365 or arg4==10437 or arg4==10438 then
                    FireTotemDuration = 40
                    FireTotemTimer = GetTime()
                    FireTotemName = "灼热图腾"

                elseif arg4==6365 then--   arg4==10437 or arg4==10438 then
                    FireTotemDuration = 45
                    FireTotemTimer = GetTime()
                    FireTotemName = "灼热图腾"
                elseif arg4==10437 then--   arg4==10438 then
                    FireTotemDuration = 50
                    FireTotemTimer = GetTime()
                    FireTotemName = "灼热图腾"

                elseif arg4==10438 then
                    FireTotemDuration = 55
                    FireTotemTimer = GetTime()
                    FireTotemName = "灼热图腾"

                -- 熔岩图腾
                elseif arg4==8190 or arg4==10585 or arg4==10586 or arg4==10587 then
                    FireTotemDuration = 20
                    FireTotemTimer = GetTime()
                    FireTotemName = "熔岩图腾"

                -- 抗寒图腾
                elseif arg4==8181 or arg4==10478 or arg4==10479 then
                    FireTotemDuration = 120
                    FireTotemTimer = GetTime()
                    FireTotemName = "抗寒图腾"

                -- 火舌图腾
                elseif arg4==8227 or arg4==8249 or arg4==10526 or arg4==16387 then
                    FireTotemDuration = 120
                    FireTotemTimer = GetTime()
                    FireTotemName = "火舌图腾"



                ----------------
                -- 水之图腾
                ----------------

                -- 抗火图腾
                elseif arg4==8184 or arg4==10537 or arg4==10538 then
                    WaterTotemDuration = 120
                    WaterTotemTimer = GetTime()
                    WaterTotemName = "抗火图腾"

                -- 治疗之泉图腾
                elseif arg4==5394 or arg4==6375 or arg4==6377 or arg4==10462 or arg4==10463 then
                    WaterTotemDuration = 60
                    WaterTotemTimer = GetTime()
                    WaterTotemName = "治疗之泉图腾"

                -- 法力之泉图腾
                elseif arg4==5675 or arg4==10495 or arg4==10496 or arg4==10497 then
                    WaterTotemDuration = 60
                    WaterTotemTimer = GetTime()
                    WaterTotemName = "法力之泉图腾"

                -- 清毒图腾
                elseif arg4==8166 then
                    WaterTotemDuration = 120
                    WaterTotemTimer = GetTime()
                    WaterTotemName = "清毒图腾"

                -- 祛病图腾
                elseif arg4==8170 then
                    WaterTotemDuration = 120
                    WaterTotemTimer = GetTime()
                    WaterTotemName = "祛病图腾"

                ----------------
                -- 空气图腾
                ----------------

                -- 岗哨图腾
                elseif arg4 == 6495 then
                    AirTotemDuration = 300
                    AirTotemTimer = GetTime()
                    AirTotemName = "岗哨图腾"

                -- 根基图腾
                elseif arg4 == 8177 then
                    AirTotemDuration = 45
                    AirTotemTimer = GetTime()
                    AirTotemName = "根基图腾"

                -- 自然抗性图腾
                elseif arg4==10595 or arg4==10600 or arg4==10601 then
                    AirTotemDuration = 120
                    AirTotemTimer = GetTime()
                    AirTotemName = "自然抗性图腾"

                -- 风之优雅图腾
                elseif arg4==8835 or arg4==10627 or arg4==25359 then
                    AirTotemDuration = 120
                    AirTotemTimer = GetTime()
                    AirTotemName = "风之优雅图腾"

                -- 风墙图腾
                elseif arg4==15107 or arg4==15111 or arg4==15112 then
                    AirTotemDuration = 120
                    AirTotemTimer = GetTime()
                    AirTotemName = "风墙图腾"

                -- 风怒图腾
                elseif arg4==8512 then
                    AirTotemDuration = 120
                    AirTotemTimer = GetTime()
                    AirTotemName = "风怒图腾"

                -- 宁静之风图腾
                elseif arg4==25908 then
                    AirTotemDuration = 120
                    AirTotemTimer = GetTime()
                    AirTotemName = "宁静之风图腾"


                -- 烈焰震击
                elseif arg4==8050 or arg4==8052 or arg4==8053 or arg4==10447 or arg4==10448 or arg4==29228 then
                    FlameShockDelayTime[arg2] = GetTime()

                --[[
                -- 熔岩爆裂
                elseif arg4==36916 or arg4==36917 or arg4==36918 or arg4==36919 or arg4==36920 or arg4==36921 then
                    LavaBurstBeginTime = GetTime()
                    ]]
                end

            end
        end

    -- 战斗日志事件处理
    elseif event == "RAW_COMBATLOG" then

        -- 自己的攻击
        if arg1 == "CHAT_MSG_SPELL_SELF_DAMAGE" then

            -- 烈焰震击
            if string.find( arg2, "你的烈焰震击.*抵抗了.*" ) then
                local targetGUID = Cat2.MatchGUID(arg2) 
                if targetGUID and FlameShockDelayTime[targetGUID] then 
                    local timer = GetTime() - FlameShockDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        FlameShockDelayTime[targetGUID] = nil
                    end
                end

            elseif string.find( arg2, "你的熔岩爆裂击中.*" ) or string.find( arg2, "你的熔岩爆裂致命一击.*" ) then
                if Cat2.GetFlameShockDot() then
                    local targetGUID = Cat2.MatchGUID(arg2) 
                    if targetGUID and FlameShockCheck[targetGUID] then
                        FlameShockCheck[targetGUID] = GetTime()
                    end
                end

                BeginLavaBurstCastTimer = GetTime()

            elseif string.find( arg2, "你的重燃烈火击中.*" ) or string.find( arg2, "你的重燃烈火致命一击.*" ) then
                if Cat2.GetFlameShockDot() then
                    local targetGUID = Cat2.MatchGUID(arg2) 
                    if targetGUID and FlameShockCheck[targetGUID] then
                        FlameShockCheck[targetGUID] = GetTime()
                    end
                end

                BeginLavaBurstCastTimer = GetTime()

            end

        end

    end

end

-- 设置事件处理函数
frame:SetScript("OnEvent", OnEvent)


function Cat2.EarthTotem()
    if GetTime()-EarthTotemTimer<EarthTotemDuration then
        return true
    end

    return false
end

function Cat2.EarthTotemName()
    return EarthTotemName
end


function Cat2.FireTotem()
    if GetTime()-FireTotemTimer<FireTotemDuration then
        return true
    end

    return false
end

function Cat2.FireTotemName()
    return FireTotemName
end


function Cat2.WaterTotem()
    if GetTime()-WaterTotemTimer<WaterTotemDuration then
        return true
    end

    return false
end

function Cat2.WaterTotemName()
    return WaterTotemName
end


function Cat2.AirTotem()
    if GetTime()-AirTotemTimer<AirTotemDuration then
        return true
    end

    return false
end

function Cat2.AirTotemName()
    return AirTotemName
end



local Cat2ShamanTooltip = CreateFrame("GameTooltip", "CAT2ShamanTooltip", UIParent, "GameTooltipTemplate")

function Cat2.GetShamanEnchantName(slot)
	slot = slot or 16

    Cat2ShamanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    Cat2ShamanTooltip:ClearLines()
    
    -- 扫描武器栏位（16=主手，17=副手）
    Cat2ShamanTooltip:SetInventoryItem("player", slot)
    
    -- 解析Tooltip
	-- 遍历所有行（最多20行）
    for i = 2, 20 do  -- 通常附魔信息从第2行开始

        local line = _G["CAT2ShamanTooltipTextLeft"..i]
        if not line then break end  -- 无更多行时退出

        local text = line:GetText() or ""

        -- 匹配附魔名称（根据客户端语言调整关键词）
        if string.find(text, "分钟") then
            if string.find(text, "风怒") then
			    Cat2ShamanTooltip:Hide()
                return "风怒武器"

            elseif string.find(text, "火舌") then
			    Cat2ShamanTooltip:Hide()
                return "火舌武器"

            elseif string.find(text, "冰霜") then
			    Cat2ShamanTooltip:Hide()
                return "冰封武器"
            elseif string.find(text, "冰封") then     -- 特殊情况，冰封(等级 3)的翻译情况
			    Cat2ShamanTooltip:Hide()
                return "冰封武器"

            elseif string.find(text, "石化") then
			    Cat2ShamanTooltip:Hide()
                return "石化武器"

            end
        end

    end
    
    Cat2ShamanTooltip:Hide()
    return ""
end



local function GetFlameShockDotCheck( guid, value )

    if FlameShockCheck[guid] then
        local timer = GetTime() - FlameShockCheck[guid]
        if timer < (ShamanFlameShockDuration-value) then
            return true
        end
    end

    return false
end

function Cat2.GetFlameShockDot(value)
    value = value or 0

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["烈焰震击"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists("target")
    if not guid then
        return false
    end

    -- BLEENCHECKDELAY秒监测期里
    if FlameShockDelayTime[guid] then 
        local timer = GetTime() - FlameShockDelayTime[guid]
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            FlameShockCheck[guid] = FlameShockDelayTime[guid]
            FlameShockDelayTime[guid] = nil
        end
    end

    return GetFlameShockDotCheck(guid, value)
end


function Cat2.GetFlameShockCheck()
    return FlameShockCheck
end

function Cat2.GetBeginLavaBurstCastTimer()
    return BeginLavaBurstCastTimer
end



