local _, playerClass = UnitClass("player")
if playerClass ~= "ROGUE" then
    return  -- 终止文件执行
end


local frame = CreateFrame("Frame")

frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
frame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")

-- SuperWow专有事件
frame:RegisterEvent("UNIT_CASTEVENT")
frame:RegisterEvent("RAW_COMBATLOG")

-- Nampower专有事件
frame:RegisterEvent("BUFF_REMOVED_SELF")



-- 能量消耗相关

-- 切割能量
local RogueSliceEnergy = 20
local RogueSliceDuration = 0
local RogueSliceTalent = 0

-- 当前连击点
local RogueCombo = 0

-- 割裂buff持续时间
local RogueBloodyDuration = 0
local RogueBloodyTalent = 0

-- 毒伤buff持续时间
local RogueEnvenomDuration = 0


-- 突袭的闪避状态
local RogueSurpriseStrikeTimer = 0
local RogueSurpriseStrikeTargetGUID = 0
local RogueSurpriseStrikeTimerNoSW = 0

-- 盗贼主手武器 1=其他 2=匕首
local RogueMainHand = 1

-- 冷血
local RogueColdBlood = 0
local RogueColdBloodTimer = 0


-- 切割buff
local SliceTimer = 0

-- 割裂buff
local BloodyTimer = 0

-- 割裂DOT监测
local RuptureCheck = {}
local RuptureDelayTime = {}
local RuptureDuration = 16


-- 毒伤buff
local EnvenomTimer = 0


local ExposeArmorCheck = {}
local ExposeArmorDelayTime = {}



-- 等待技能反馈的等待时间
local BLEENCHECKDELAY = 0.3

local function OnEvent()

    if event == "PLAYER_DEAD" then
        SliceTimer = 0
        BloodyTimer = 0
        EnvenomTimer = 0
        ExposeArmorCheck = {}
        ExposeArmorDelayTime = {}
        RogueSurpriseStrikeTimer = 0
        RogueSurpriseStrikeTargetGUID = 0
        RogueSurpriseStrikeTimerNoSW = 0


    elseif event == "CHAT_MSG_COMBAT_SELF_MISSES" then
        if not Cat2.SuperWoW then
            if string.find( arg1, "你发起了攻击.*闪开了.*" ) or string.find( arg1 or "", "Your attack.*dodg" ) then
                RogueSurpriseStrikeTimerNoSW = GetTime()
            end
        end

    elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
        if not Cat2.SuperWoW then
            if string.find( arg1, "你的.*躲闪.*" ) or string.find( arg1 or "", "dodg" ) then
                RogueSurpriseStrikeTimerNoSW = GetTime()
            elseif string.find( arg1, ".*突袭.*" ) or string.find( arg1 or "", "Surprise" ) then
                RogueSurpriseStrikeTimerNoSW = 0
            end
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

                --print(arg4)
                -- 冷血id 14177

                -- 突袭
                if arg4 == 52511 then
			        RogueSurpriseStrikeTimer=0

                -- 割裂
                elseif arg4== 11275 then
                    if Cat2.IsTalentLearned(1, 10)==1 then RogueBloodyTalent=4 
                    elseif Cat2.IsTalentLearned(1, 10)==2 then RogueBloodyTalent=6 end
                    RogueBloodyDuration = 6+(RogueCombo*2) + RogueBloodyTalent
                    BloodyTimer = GetTime()

                    -- 切割dot
                    RuptureDelayTime[arg2] = GetTime()
                    RuptureDuration = 6+RogueCombo*2

                -- 血腥气息
                elseif arg4==52529 or arg4 == 52530 then
                    if Cat2.IsTalentLearned(1, 10)==1 then RogueBloodyTalent=4 
                    elseif Cat2.IsTalentLearned(1, 10)==2 then RogueBloodyTalent=6 end
                    RogueBloodyDuration = 6+(RogueCombo*2) + RogueBloodyTalent
                    BloodyTimer = GetTime()

                -- 毒伤
                elseif arg4 == 52531 then
                    RogueEnvenomDuration = 8+(RogueCombo*4)
                    EnvenomTimer = GetTime()


                -- 切割
                elseif arg4 == 6774 then
                    -- 计算应该持续时间
                    RogueSliceDuration = 6+(RogueCombo*3)
                    RogueSliceTalent = 1+Cat2.IsTalentLearned(1, 6)*0.15
                    if RogueSliceTalent>0 then
                        RogueSliceDuration = RogueSliceDuration * RogueSliceTalent
                    end

                    SliceTimer = GetTime()

                -- 破甲
                elseif arg4 == 11198 then
                    ExposeArmorDelayTime[arg2] = GetTime()
                    ExposeArmorCombo = RogueCombo

                else

                    --MPMsg(arg4)

                end


            end

        end

    -- 战斗日志事件处理
    elseif event == "RAW_COMBATLOG" then

        -- 自己的攻击
        if arg1 == "CHAT_MSG_COMBAT_SELF_MISSES" then
            --print(arg2)
            if string.find( arg2, "你发起了攻击.*闪开了.*" ) or string.find( arg2 or "", "Your attack.*dodg" ) then
                local guid = Cat2.MatchGUID(arg2)
                if guid then
                    RogueSurpriseStrikeTimer = GetTime()
                    RogueSurpriseStrikeTargetGUID = guid
                end
            end

        elseif arg1 == "CHAT_MSG_SPELL_SELF_DAMAGE" then
            --print(arg2)

            if string.find( arg2, "你的.*躲闪.*" ) or string.find( arg2 or "", "dodg" ) then
                local guid = Cat2.MatchGUID(arg2)
                if guid then
                    RogueSurpriseStrikeTimer = GetTime()
                    RogueSurpriseStrikeTargetGUID = guid
                end
            
            -- 破甲
            elseif string.find( arg2, "你的破甲.*招架.*" ) or string.find( arg2, "你的破甲.*躲闪.*" ) or string.find( arg2, "你的破甲.*格挡.*" ) or string.find( arg2, "你的破甲.*没有击中.*" ) or ( string.find(arg2 or "", "Your Expose Armor") and ( string.find(arg2 or "", "dodg") or string.find(arg2 or "", "parr") or string.find(arg2 or "", "block") or string.find(arg2 or "", "miss") ) ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and ExposeArmorDelayTime[targetGUID] then 
                    local timer = GetTime() - ExposeArmorDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        ExposeArmorDelayTime[targetGUID] = nil
                    end
                end

            -- 割裂
            elseif string.find( arg2, "你的割裂.*招架.*" ) or string.find( arg2, "你的割裂.*躲闪.*" ) or string.find( arg2, "你的割裂.*格挡.*" ) or string.find( arg2, "你的割裂.*没有击中.*" ) then
                local targetGUID = Cat2.MatchGUID(arg2)
                if targetGUID and RuptureDelayTime[targetGUID] then 
                    local timer = GetTime() - RuptureDelayTime[targetGUID]
                    if timer <= BLEENCHECKDELAY then
                        RuptureDelayTime[targetGUID] = nil
                    end
                end

            end

        end

    elseif event == "BUFF_REMOVED_SELF" then

        --local spellname = GetSpellRecField(arg3, "name")
        --MPMsg(arg3.."-"..spellname)

        -- 冷血 消耗
        if arg3 == 14177 then
            RogueColdBloodTimer = GetTime()+180
        end

    end


end



local function OnUpdate()
    RogueCombo = GetComboPoints("target")
end


-- 设置事件处理函数
frame:SetScript("OnEvent", OnEvent)
frame:SetScript("OnUpdate", OnUpdate)






function Cat2.GetRogueBloody(leaveTime)

    leaveTime = leaveTime or 0;

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.buff["血腥气息"]
    end
    

    if (GetTime()-BloodyTimer) < (RogueBloodyDuration-leaveTime) then
        return true
    end

    return false
end


function Cat2.GetRogueEnvenom(leaveTime)

    leaveTime = leaveTime or 0;

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.buff["毒伤"]
    end
    

    if (GetTime()-EnvenomTimer) < (RogueEnvenomDuration-leaveTime) then
        return true
    end

    return false
end


function Cat2.GetRogueSlice(leaveTime)

    leaveTime = leaveTime or 0;

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.buff["切割"]
    end
    

    if (GetTime()-SliceTimer) < (RogueSliceDuration-leaveTime) then
        return true
    end

    return false
end





-- 获取当前目标是否有破甲效果
-- 注：SuperWow支持更加准确
-- return 存在返回真

local function GetExposeArmorDOTCheck( guid, value )

    if ExposeArmorCheck[guid] then
        local timer = GetTime() - ExposeArmorCheck[guid]
        if timer < (30-value) then
            return true
        end
    end

    return false
end

function Cat2.GetExposeArmorDot(value)

    value = value or 0

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["破甲"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists("target")
    if not guid then
        return false
    end

    if ExposeArmorDelayTime[guid] then 
        local timer = GetTime() - ExposeArmorDelayTime[guid]
        -- 0.2秒监测期里
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            ExposeArmorCheck[guid] = ExposeArmorDelayTime[guid]
        end
    end

    return GetExposeArmorDOTCheck(guid, value)
end



-- 获取当前目标是否有割裂效果
-- 注：SuperWow支持更加准确
-- return 存在返回真

local function GetRuptureDOTCheck( guid, value )

    if RuptureCheck[guid] then
        local timer = GetTime() - RuptureCheck[guid]
        if timer < (RuptureDuration-value) then
            return true
        end
    end

    return false
end

function Cat2.GetRuptureDot(value)

    value = value or 0

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW or Cat2.PlayerInformation.basic.level<60 then
        return Cat2.PlayerInformation.temporary.targetBuff["割裂"]
    end

    -- 获取目标GUID，并确保其存在
    local a,guid=UnitExists("target")
    if not guid then
        return false
    end

    if RuptureDelayTime[guid] then 
        local timer = GetTime() - RuptureDelayTime[guid]
        -- 0.2秒监测期里
        if timer <= BLEENCHECKDELAY then
            -- 还在等待认证期
            return true
        else
            -- 已经过了认证期
            RuptureCheck[guid] = RuptureDelayTime[guid]
        end
    end

    return GetRuptureDOTCheck(guid, value)
end





function Cat2.RogueColdBloodReady()
    if not Cat2.PlayerInformation.temporary.buff["冷血"] then
        if Cat2.SpellReady("冷血") then
            if RogueColdBloodTimer<GetTime() then
                return true
            end
        end
    end

    return false
end



-- 获取盗贼突袭状态
function Cat2.RogueSurpriseStrike()

    -- 检测是否有SuperWow模组
    if not Cat2.SuperWoW then
		if GetTime()-RogueSurpriseStrikeTimerNoSW<4 then
			return true
		end
        return false
    end

	if GetTime()-RogueSurpriseStrikeTimer<4 then

		-- 是否存在有效目标
		local a,guid=UnitExists("target")
		if not guid then
			return false
		end

		-- 校验GUID是否是触发压制的目标
		if guid == RogueSurpriseStrikeTargetGUID then
			return true
		end
	end

	return false
end


local PostionNametip = CreateFrame("GameTooltip", "Cat2PostionNametip", nil, "GameTooltipTemplate")

-- 检查主手毒药类型
function Cat2.GetMainHandPostion()
	PostionNametip:SetOwner(UIParent, "ANCHOR_NONE")
    PostionNametip:ClearLines()
    PostionNametip:SetInventoryItem("player", 16)   -- 主手
    -- 扫描 Tooltip 文本
    for i = 2, PostionNametip:NumLines() do
        local line = _G["Cat2PostionNametipTextLeft"..i]
        if line then
            local text = line:GetText() or ""
            if string.find(text, "毒药") then
                return text
            end
        end
    end

    return nil
end


-- 检查副手毒药类型
function Cat2.GetOffHandPostion()
	PostionNametip:SetOwner(UIParent, "ANCHOR_NONE")
    PostionNametip:ClearLines()
    PostionNametip:SetInventoryItem("player", 17)   -- 副手
    -- 扫描 Tooltip 文本
    for i = 2, PostionNametip:NumLines() do
        local line = _G["Cat2PostionNametipTextLeft"..i]
        if line then
            local text = line:GetText() or ""
            if string.find(text, "毒药") then
                return text
            end
        end
    end

    return nil
end


-- 切换包里武器，根据毒药来进行选择
function Cat2.RogueSwitchWeapon(postion, inventory)

    local speed_bag,speed_slot
    local speed = 0
    local dps = 0
    local weapon_dps = 0

	PostionNametip:SetOwner(UIParent, "ANCHOR_NONE")
	local bag, slot
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                PostionNametip:ClearLines()
                PostionNametip:SetBagItem(bag, slot)

                -- 扫描 Tooltip 文本
                for i = 2, PostionNametip:NumLines() do

                    -- 先找到有毒药的武器
                    local line = _G["Cat2PostionNametipTextLeft"..i]
                    if line then
                        local text = line:GetText() or ""

                        local local_dps = Cat2.Match(text, "每秒伤害(%d+%.?%d*)")
                        if local_dps then
                            weapon_dps = Cat2.ToNumber(local_dps)
                        end

                        if string.find(text, postion) then
                            local _, _, name = string.find(itemLink, "%[(.-)%]")
                            --print(name)

                            -- 判断武器攻速
                            for j = 2, 6 do
                                local right = _G["Cat2PostionNametipTextRight"..j]
                                if right then
                                    local text_right = right:GetText() or ""

                                    local Value = Cat2.ToNumber(Cat2.Match(text_right, "速度 (%d+%.?%d*)"))
                                    --print(Value)
                                    if Value and Value>0 then
                                        
                                        --MPMsg(name.."speed "..speed.." - "..Value)
                                        --MPMsg(name.."dps "..dps.." - "..weapon_dps)
                                        --MPMsg("bag="..bag.."  slot="..slot)
                                        if speed < Value then
                                            speed = Value
                                            speed_bag = bag
                                            speed_slot = slot
                                            dps = weapon_dps
                                        elseif speed == Value then
                                            -- 攻速一样的情况下，看秒伤
                                            if weapon_dps and dps < weapon_dps then
                                                speed = Value
                                                speed_bag = bag
                                                speed_slot = slot
                                                dps = weapon_dps
                                            end
                                        end
                                        break
                                    end
                                end
                            end


                        end
                    end
                end
            end
        end
    end

    if speed_bag and speed_slot then
        PickupContainerItem(speed_bag, speed_slot)
		EquipCursorItem(inventory)
    end
end




