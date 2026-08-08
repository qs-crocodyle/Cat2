-- Cat2 通用游戏 API 兼容库。
-- 这里封装施法、物品、天赋、目标与字符串处理等低层能力，供卡片 Execute 按需调用。
-- 文件保留旧项目兼容写法与部分全局 API 探测；重构前应先确认对应卡片仍在使用。
_G = getfenv()


local function GetChatFrameByName(frameName)
    for i = 1, NUM_CHAT_WINDOWS do
        local name = GetChatWindowInfo(i)
        if name and name == frameName then
            return _G["ChatFrame"..i]
        end
    end
    return nil
end

-- 将调试信息打印在Cat频道窗口里
function Cat2.Msg(str)

    if not str then
        return
    end

	local chat = GetChatFrameByName("Cat")
	if not chat then chat = GetChatFrameByName("CAT") end
	if not chat then chat = GetChatFrameByName("cat") end

	if chat then
		local timeTable = date("*t")
		chat:AddMessage("|cFF9264cdCat|r |cFFc3a7e2["..string.format("%02d",timeTable.hour)..":"..string.format("%02d",timeTable.min)..":"..string.format("%02d",timeTable.sec).."] |r "..str)
	end
end



-- 获取天赋参数
function Cat2.IsTalentLearned(tabIndex, talentIndex)
	local _, _, _, _, rank = GetTalentInfo(tabIndex, talentIndex)
	return rank
end




-- 选择远处目标
-- 需要UnitXP模组
function Cat2.SwitchDistantTarget(value)
	value = value or 1

	if value==0 then
		return
	end

	if not Cat2.UnitXP then
		return
	end

	-- 当前有目标
	local t = UnitExists("target")
	if t then
		local dist = UnitXP("distanceBetween", "player", "target")
		if dist then

			if dist<8 or dist>41 then
				-- 无效距离
			else
				-- 有效距离，不切换
				return
			end
		end
	end

    local list = {}
    local count = 0

    _,count,_,_,list = Cat2.ScanNearbyEnemiesCount()

    if count==0 then
        --pirnt("周围没有敌人")
        return
    end

	local farway = 0
	local target = nil

	for key, value in pairs(list) do
		local dist = UnitXP("distanceBetween", "player", key)

		-- 距离41码内
		if dist and dist<41 and dist > farway then

			-- 目标 1可以攻击 2未死亡 3已进入战斗 4排除小动物
			if UnitCanAttack("player", key) and not UnitIsDeadOrGhost(key) and UnitAffectingCombat(key) and UnitCreatureType(key) ~= "小动物" then

				-- 正面朝向
				if not UnitXP("behind", key, "player") then

					-- 视野中
					local inS = UnitXP("inSight", "player", key)
					if inS then
						farway = dist
						target = key
					end

				end
			end

		end
	end

	-- 选择扫描后目标
	if target~=nil then
		TargetUnit(target)
	end

end











-- 获取技能是否CD结束
-- name技能名称
-- return 获取成立返回真
function Cat2.SpellReady(name)
	local spell_id = Cat2.GetSpellID(name)

	-- 不存在该技能
	if spell_id == 0 then
		return false
	end

	if GetSpellCooldown(spell_id, "spell") == 0 then
		return true
	end
	return false
end



-- 获取技能是否CD结束，增加可以判断还差多久结束
-- name技能名称，offset偏移值，空为默认0.5秒
-- return 获取成立返回真
function Cat2.SpellReadyOffset(name,offset)

	-- 不存在该技能
	if Cat2.GetSpellID(name) == 0 then
		return false
	end

	if not offset then offset=0.5 end
	if Cat2.GetSpellCooldown(name) <offset then
		return true
	end
	return false
end

function Cat2.GetSpellCooldown(spell)
	local i = Cat2.GetSpellID(spell)

	-- 不存在该技能
	if i==0 then
		return 0
	end

	local start, dur = GetSpellCooldown(i, "spell")
	local time = dur-(GetTime()-start);
	if time < 0 then time=0 end
	return time
end

-- 获取技能是否存在
-- name技能名称
-- return 获取成立返id
function Cat2.GetSpellID(name, rank)
	local i = 0
	local spellName = " "
	while spellName ~= nil do
		i = i + 1
		spellName, spellRank = GetSpellName(i, "spell")

		if rank then
			if spellName==name and spellRank== rank then
				return i
			end
		else
			if spellName==name then
				return i
			end
		end
	end
	return 0
end


------------------------
-- 施法
------------------------

function Cat2.CastSpellWithoutTarget(spellName, unit, tip)

	tip = tip or 0;

	if not unit then
		return false
	end

	if tip>0 then
		local name = UnitName(unit)
		if name then
			Cat2.Msg(spellName.."-> ["..UnitName(unit).."]")
		end
	end

	-- 保存当前目标
	local obj,oldTargetGUID = UnitExists("target")

	-- 临时选中目标
	if unit == "target" then
	else
		TargetUnit(unit)
	end
    
	-- 施法
	if UnitIsVisible(unit) then

		Cat2.CastWithoutNampower(spellName)

		-- 恢复原来的目标
		if unit ~= "target" then
			if obj then
				TargetUnit(oldTargetGUID)
			else
				ClearTarget()
			end
		end

	else
		-- 恢复原来的目标
		if unit ~= "target" then
			if obj then
				TargetUnit(oldTargetGUID)
			else
				ClearTarget()
			end
		end

		return false
	end

	return true
end



function Cat2.Cast(spellName, unit)
	local NP_QueueChannelingSpells
	if Cat2.Nampower then
		NP_QueueChannelingSpells = GetCVar("NP_QueueChannelingSpells")
		if NP_QueueChannelingSpells ~= 0 then
			SetCVar("NP_QueueChannelingSpells", 0)
		end
	end

	CastSpellByName(spellName, unit)

	if Cat2.Nampower then
		SetCVar("NP_QueueChannelingSpells", NP_QueueChannelingSpells)
	end

end

function Cat2.CastWithNampower(spellName, unit)
	if Cat2.Nampower then
		QueueSpellByName(spellName)
	else
		CastSpellByName(spellName)
	end
end

function Cat2.CastWithoutNampower(spellName)
	if Cat2.Nampower then
		local CS = GetCVar("NP_QueueCastTimeSpells")
		local IS = GetCVar("NP_QueueInstantSpells")
		SetCVar("NP_QueueCastTimeSpells", "0")
		SetCVar("NP_QueueInstantSpells", "0")
		CastSpellByName(spellName)
		SetCVar("NP_QueueCastTimeSpells", CS)
		SetCVar("NP_QueueInstantSpells", IS)
		--SetCVar("NP_QueueCastTimeSpells", "1")
		--SetCVar("NP_QueueInstantSpells", "1")
	else
		CastSpellByName(spellName)
	end
end


-- 施法的替代宏，针对Nampower的施法队列
-- 使用方法同CastSpellByName
function Cat2.CastSpell(spellName)
	if Cat2.Nampower then
		QueueSpellByName(spellName)
	else
		CastSpellByName(spellName)
	end
end




-- 获取当前姿态，战士、德鲁伊可用
-- id顺序1-6
-- return 获取到返回真
function Cat2.GetShape(id)
	if not id or id<=0 then
		return false
	end

	local _,_,a=GetShapeshiftFormInfo(id)
	if a then return true end

	return false
end


-- 切换姿态
function Cat2.SetShape(shapename)
	if not shapename then
		return false
	end

	for i = 1, 6 do
		local _, name, a, id = GetShapeshiftFormInfo(i)
        if name and name==shapename then
            if a then return true end
            break
        end
	end

	return false
end



-- 取消德鲁伊形态
function Cat2.ResetShapes()
	for i=1, GetNumShapeshiftForms() do
		local _,_,a = GetShapeshiftFormInfo(i)
		if a then
			CastShapeshiftForm(i)
		end
	end
end


-- 使用背包中物品
-- itemName 物品名
-- return 存在为真
function Cat2.UseItemByName(itemName)
	local bag, slot
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local _, _, name = string.find(itemLink, "%[(.-)%]")
                if name == itemName then
					local startTime, duration, enable = GetContainerItemCooldown(bag, slot)
					if enable then
						if duration-(GetTime()-startTime) <= 1 then
							UseContainerItem(bag, slot)
							return true
						end
					end
                    return false
                end
            end
        end
    end

    return false
end

-- 对自己使用背包中物品（用于防止没开启对自己施法的情况）
-- itemName 物品名
-- return 存在为真
function Cat2.UseItemByNameToSelf(itemName)

	if Cat2.GetItemByNameCD(itemName) then

        local target,guid = UnitExists("target")

        TargetUnit("player")
		Cat2.UseItemByName(itemName)

        if not target then
            ClearTarget()
        else
            TargetUnit(guid)
        end
	end

end

-- 检查背包中物品CD
-- return 存在为真
function Cat2.GetItemByNameCD(itemName)
	local bag, slot
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local _, _, name = string.find(itemLink, "%[(.-)%]")
                if name == itemName then
					local startTime, duration, enable = GetContainerItemCooldown(bag, slot)
					if duration-(GetTime()-startTime) <= 1 then
						return true
					end
                    return false
                end
            end
        end
    end

    return false
end

-- 检查背包中物品ID
-- return id
function Cat2.GetItemByNameID(itemName)
	local bag, slot
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local _, _, name = string.find(itemLink, "%[(.-)%]")
                if name == itemName then
					local itemID = Cat2.Match(itemLink, "item:(%d+):")
					if itemID then
						return Cat2.ToNumber(itemID)
					end
                end
            end
        end
    end

    return 0
end

-- 检查背包中物品数量
-- return 数量
function Cat2.GetItemByNameCount(itemName)
	local bag, slot
	local count = 0
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local _, _, name = string.find(itemLink, "%[(.-)%]")
                if name == itemName then
					local _,c = GetContainerItemInfo(bag,slot)
					if c then
						if c<0 then
							count = count + (c*-1)
						else
							count = count+c
						end
					end
                end
            end
        end
    end

    return count
end

-- 获取背包中物品贴图
-- return 
function Cat2.GetItemTexByName(itemName)
	local bag, slot
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local _, _, name = string.find(itemLink, "%[(.-)%]")
                if name == itemName then
                    return GetContainerItemInfo(bag, slot)
                end
            end
        end
    end

    return nil
end

-- 背包里装备穿戴到身上
function Cat2.EquipItemByName(itemName, inventory)
	local bag, slot
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local _, _, name = string.find(itemLink, "%[(.-)%]")
                if name == itemName then
                    PickupContainerItem(bag, slot)
					EquipCursorItem(inventory)
                    return true
                end
            end
        end
    end

    return false
end




-- 是否打开交互窗口（银行、邮箱、拍卖行、商人）
function Cat2.CheckUIStatus()

	if IsBankOpen() then
		return true
	end

	if IsAuctionHouseOpen() then
		return true
	end

	if IsMailboxOpen() then
		return true
	end

	if IsMerchantOpen() then
		return true
	end

	return false
end



-- 获取技能文字描述
-- spellName 技能名字
-- spellRank 技能等级，如："等级 8"
-- 返回string
local SpellTooltip = CreateFrame("GameTooltip", "Cat2SpellTooltip", UIParent, "GameTooltipTemplate")

function Cat2.GetSpellTooltip(spellName, spellRank)

	SpellTooltip:SetOwner(UIParent, "ANCHOR_NONE") -- 隐藏锚点
	SpellTooltip:ClearLines()

	local spellID = Cat2.GetSpellID(spellName, spellRank)

	-- 技能不存在
	if spellID==0 then
		return
	end

    SpellTooltip:SetSpell(spellID, "spell")

    -- 提取 Tooltip 文本
    local TooltipText = ""
    for i = 1, 10 do  -- 1.12 Tooltip 通常不超过 10 行
        local line = getglobal("Cat2SpellTooltipTextLeft" .. i)
        if line and line:GetText() then
            TooltipText = TooltipText .. line:GetText() .. "\n"
        end
    end

    -- 清理 Tooltip
    SpellTooltip:Hide()
    return TooltipText
end


-- 获取技能最高等级
-- spellName 技能名字
-- spellRank 技能等级，如："回春术"
-- 返回int
function Cat2.GetHighestRankOfSpell(spellName)
    local highestRank = 0
    local highestSpellIndex = nil
    
    local i = 1
    while true do

        local name, rank = GetSpellName(i, BOOKTYPE_SPELL)
        
        if not name then
            break
        end
        
        if name == spellName then
            local currentRank = 1  -- 默认等级为1
            
            -- 解析等级文本（处理各种格式）
            if rank and rank ~= "" then
                -- 匹配数字（适用于"Rank 3", "等级 3", "级别 3"等格式）
                local rankNum = Cat2.Match(rank, "(%d+)")
                if rankNum then
                    currentRank = Cat2.ToNumber(rankNum)
                end
                -- 如果没有匹配到数字，保持默认等级1
            end
            
            if currentRank > highestRank then
                highestRank = currentRank
                highestSpellIndex = i
            end
        end
        
        i = i + 1
        -- 安全限制，防止无限循环
        if i > 300 then break end
    end
    
    return highestRank, highestSpellIndex
end



local HealingPowerScannerTooltip = CreateFrame("GameTooltip", "Cat2HealingPowerScannerTooltip", nil, "GameTooltipTemplate")
HealingPowerScannerTooltip:SetOwner(UIParent, "ANCHOR_NONE")

function Cat2.CalculateTotalHealingPower()
    local totalHealing = 0
    
    -- 装备栏位列表（经典旧世版本）
    local slotNames = {
        "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot",
        "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot",
        "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot",
        "MainHandSlot", "SecondaryHandSlot", "RangedSlot"
    }
        
    -- 遍历所有装备栏位
    for _, slotName in ipairs(slotNames) do
        local slotID = GetInventorySlotInfo(slotName)
        if slotID then

            HealingPowerScannerTooltip:ClearLines()
            HealingPowerScannerTooltip:SetInventoryItem("player", slotID)  -- 关键修正
            -- 扫描 Tooltip 文本
            for i = 2, HealingPowerScannerTooltip:NumLines() do
                local line = _G["Cat2HealingPowerScannerTooltipTextLeft"..i]
                if line then
                    local text = line:GetText() or ""
                    local healingValue = Cat2.Match(text, "治疗效果，最多(%d+)点")
                    if healingValue then
                        totalHealing = totalHealing + Cat2.ToNumber(healingValue)
                    end

					healingValue = Cat2.Match(text, "治疗效果提高最多(%d+)")
                    if healingValue then
                        totalHealing = totalHealing + Cat2.ToNumber(healingValue)
                    end
                end
            end

        end
    end
    
    --print("总法术治疗量: " .. totalHealing)
    return totalHealing
end





-- 判定副手武器类型是盾牌
function Cat2.IsOffHandShield()
    local itemLink = GetInventoryItemLink("player", 17)
    local itemID = Cat2.Match(itemLink, "item:(%d+):")
    if itemLink then
        local _, _, _, _, _, itemType = GetItemInfo(itemID)
        return itemType == "盾牌"
    end
    
    return false
end

-- 判定主手武器类型是匕首
function Cat2.IsMainHandDagger()
    local itemLink = GetInventoryItemLink("player", 16)
    local itemID = Cat2.Match(itemLink, "item:(%d+):")
    if itemLink then
        local _, _, _, _, _, itemType = GetItemInfo(itemID)
        return itemType == "匕首"  -- 注意：英文可能是"Dagger" or "Daggers" 
    end
    
    return false
end


-- 是否装备双手武器
function Cat2.IsTwoHand()
    local mainHand = GetInventoryItemLink("player", 16)  -- 主手武器槽(16)
    local offHand = GetInventoryItemLink("player", 17)   -- 副手武器槽(17)
    
    -- 如果有副手武器，则是双持
    if offHand then
        return false
    end
       
    -- 默认情况(无武器或单手武器+无副手)
    return true
end

-- 远程武器类型
function IsRangedThrownWeapon()
    local itemLink = GetInventoryItemLink("player", 18)  -- 18=远程武器栏位
    if not itemLink then return false end

	local itemID = Cat2.Match(itemLink, "item:(%d+):")
    if not itemID then return false end

	local _,_,_,_,_,itemSubType = GetItemInfo(itemID)
	if itemSubType=="投掷武器" then 
		return true 
	end

	return false
end



-- 检查身上装备格子的装备名称
function Cat2.CheckInventoryItemName(slot, name)
	local Link = GetInventoryItemLink("player",slot)
	if Link and strfind(Link,name) then return true end
	return false
end

-- 获取天赋参数
function Cat2.IsTalentLearned(tabIndex, talentIndex)
	local _, _, _, _, rank = GetTalentInfo(tabIndex, talentIndex)
	return rank
end



function Cat2.MatchGUID(str, length)
    -- 生成 0x + N 位十六进制的模式
    local pattern = "0x" .. string.rep("%x", length or 16)  -- 默认 16 位
    local start, finish = string.find(str,pattern)
    return start and string.sub(str, start, finish) or nil
end


function Cat2.ExtractNumber(text)

    -- 降级方案：用 string.find + string.sub
    local leftPos = string.find(text, "（") or string.find(text, "%(")
    local rightPos = string.find(text, "）") or string.find(text, "%)")
    if leftPos and rightPos then
        return string.sub(text, leftPos + 1, rightPos - 1)
    end

end


function Cat2.ToNumber(str)

	if not str then
		return 0
	end

    local number = 0
    local i = 1
    while true do
        local char = string.sub(str, i, i)
        if char == "" then break end  -- 超出字符串长度
        
        local byte = string.byte(char)
        if byte >= 48 and byte <= 57 then  -- '0'-'9'
            number = number * 10 + (byte - 48)
        end
        i = i + 1
    end
    return number	
end


function Cat2.Match(str, pattern, index)
	if type(str) ~= "string" and type(str) ~= "number" then
		return nil--error(format("bad argument #1 to 'match' (string expected, got %s)", str and type(str) or "no value"), 2)
	elseif type(pattern) ~= "string" and type(pattern) ~= "number" then
		return nil--error(format("bad argument #2 to 'match' (string expected, got %s)", pattern and type(pattern) or "no value"), 2)
	elseif index and type(index) ~= "number" and (type(index) ~= "string" or index == "") then
		return nil--error(format("bad argument #3 to 'match' (number expected, got %s)", index and type(index) or "no value"), 2)
	end

	local i1, i2, match, match2 = string.find(str, pattern, index)

	if not match and i2 and i2 >= i1 then
		return sub(str, i1, i2)
	elseif match2 then
		local matches = {string.find(str, pattern, index)}
		tremove(matches, 2)
		tremove(matches, 1)
		return unpack(matches)
	end

	return match
end

function Cat2.CleanString(str)
    return string.gsub(str, "[%z\1-\31]", "")  -- 移除控制字符
end







function Cat2.ClickReplace()

    -- 弹窗是否存在
    if StaticPopup1 and StaticPopup1:IsVisible() then
        local str=StaticPopup1Text:GetText() or ""
        if string.find(str,"替换") then
            StaticPopup1Button1:Click()
        end
    end

end



------------------
-- 治疗宏相关
------------------


-- 洗牌
function Cat2.ShuffleTable(t)
    if not t or type(t) ~= "table" then
        return {}
    end
    
    local result = {}
    local n = table.getn(t)
    
    for i = 1, n do
        result[i] = t[i]
    end
    
    for i = n, 2, -1 do
        local j = math.random(1, i)
        result[i], result[j] = result[j], result[i]
    end
    
    return result
end

-- 获取团队成员并按血量降序排序
function Cat2.GetSortedGroupByHealth()
    local members = Cat2.GetGroupHealthList()
    return Cat2.SortByHealthPercentAsc(members)
end

-- 获取小队成员并按血量降序排序
function Cat2.GetSortedPartyByHealth()
    local members = Cat2.GetPartyHealthList()
    return Cat2.SortByHealthPercentAsc(members)
end


-- 血量百分比的排序
function Cat2.SortByHealthPercentAsc(members)
    table.sort(members, function(a, b)
        local aPercent = a.health / a.maxHealth
        local bPercent = b.health / b.maxHealth
        return aPercent < bPercent
    end)
    return members
end



-- 获取团队成员并按（最大）血量升序排序
function Cat2.GetSortedGroupByMaxHealth()
    local members = Cat2.GetGroupHealthList()
    return Cat2.SortByMaxHealthAsc(members)
end

-- 最大血量的排序
function Cat2.SortByMaxHealthAsc(members)
    table.sort(members, function(a, b)
        return a.maxHealth > b.maxHealth
    end)
    return members
end



function Cat2.GetPartyHealthList()
    local groupMembers = {}
    
    local numPartyMembers = GetNumPartyMembers()
        
    -- 先添加玩家自己
    table.insert(groupMembers, {
        name = UnitName("player"),
        health = UnitHealth("player"),
        maxHealth = UnitHealthMax("player"),
        unit = "player",
        isPlayer = true
    })
        
    -- 添加队友（如果有）
    if numPartyMembers > 0 then
        for i = 1, numPartyMembers do
            local unit = "party" .. i
            if UnitExists(unit) and UnitIsVisible(unit) then
                table.insert(groupMembers, {
                    name = UnitName(unit),
                    health = UnitHealth(unit),
                    maxHealth = UnitHealthMax(unit),
                    unit = unit,
                    isPlayer = true
                })
            end
        end
    end
    
    return groupMembers
end



function Cat2.GetGroupHealthList()
    local groupMembers = {}
    
    -- 先检查是否在团队（经典旧世团队和队伍互斥）
    local numRaidMembers = GetNumRaidMembers()
    if numRaidMembers > 0 then
        -- 处理团队（最多40人）
        for i = 1, numRaidMembers do
            local unit = "raid" .. i
            if UnitExists(unit) and UnitIsVisible(unit) then
                table.insert(groupMembers, {
                    name = UnitName(unit),
                    health = UnitHealth(unit),
                    maxHealth = UnitHealthMax(unit),
                    unit = unit,
                    isPlayer = UnitIsUnit(unit, "player")
                })
            end
        end
    else
        -- 不在团队，检查是否在队伍
        local numPartyMembers = GetNumPartyMembers()
        
        
        -- 添加队友（如果有）
        if numPartyMembers > 0 then
            for i = 1, numPartyMembers do
                local unit = "party" .. i
                if UnitExists(unit) and UnitIsVisible(unit) then
                    table.insert(groupMembers, {
                        name = UnitName(unit),
                        health = UnitHealth(unit),
                        maxHealth = UnitHealthMax(unit),
                        unit = unit,
                        isPlayer = true
                    })
                end
            end
        end

        -- 最后添加玩家自己
        table.insert(groupMembers, {
            name = UnitName("player"),
            health = UnitHealth("player"),
            maxHealth = UnitHealthMax("player"),
            unit = "player",
            isPlayer = true
        })
    end
    
    return groupMembers
end







