-- Cat2 通用游戏 API 兼容库。
-- 这里封装施法、物品、天赋、目标与字符串处理等低层能力，供卡片 Execute 按需调用。
-- 文件保留旧项目兼容写法与部分全局 API 探测；重构前应先确认对应卡片仍在使用。
_G = getfenv()

local originalCastSpellByName = CastSpellByName
function CastSpellByName(spellName, unit)
    local localizedName = Cat2.L.Spell(spellName)
    if unit then
        originalCastSpellByName(localizedName, unit)
    else
        originalCastSpellByName(localizedName)
    end
end


local function GetChatFrameByName(frameName)
    for i = 1, NUM_CHAT_WINDOWS do
        local name = GetChatWindowInfo(i)
        if name and name == frameName then
            return _G["ChatFrame"..i]
        end
    end
    return nil
end

-- 获取聊天框架（支持模糊匹配名称）
function Cat2.GetChatFrameByName(frameName)
    if type(frameName) ~= "string" or frameName == "" then
        return nil
    end

    local requestedName = string.lower(frameName)
    for i = 1, NUM_CHAT_WINDOWS do
        local name = GetChatWindowInfo(i)
        if name and (name == frameName or string.lower(name) == requestedName) then
            return _G["ChatFrame"..i]
        end
    end
    return nil
end

-- ���԰�ԭʼ�ı�д��ָ����撰������չ��ڣ����ڲ�����ʱ�ɵ��÷������Ƿ���ˡ�
function Cat2.AddMessageToChatFrame(str, frameName)
    if not str then
        return false
    end
    local chat = Cat2.GetChatFrameByName(frameName)
    if not chat then
        return false
    end
    chat:AddMessage(str)
    return true
end


-- 将调试信息打印在Cat频道窗口里
function Cat2.Msg(str)

    if not str then
        return
    end

	local chat = Cat2.GetChatFrameByName("Cat")
	if not chat then chat = GetChatFrameByName("CAT") end
	if not chat then chat = GetChatFrameByName("cat") end

	if chat then
		local timeTable = date("*t")
		chat:AddMessage("|cFF9264cdCat|r |cFFc3a7e2["..string.format("%02d",timeTable.hour)..":"..string.format("%02d",timeTable.min)..":"..string.format("%02d",timeTable.sec).."] |r "..str)
	end
end

-- 可选扩展事件在未安装对应模组时可能不是合法事件。
-- 统一保护注册，失败时仅关闭对应能力，不中断当前文件继续加载。
function Cat2.RegisterOptionalEvent(frame, eventName)
	if not frame or type(eventName) ~= "string" or eventName == "" then
		return false
	end
	return pcall(frame.RegisterEvent, frame, eventName)
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

    count,_,list = Cat2.ScanNearbyEnemies()

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
			if UnitCanAttack("player", key) and not UnitIsDeadOrGhost(key) and UnitAffectingCombat(key) and UnitCreatureType(key) ~= Cat2.L("小动物") then

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

-- 返回技能自身的剩余冷却时间，并过滤旧客户端把公共冷却作为技能冷却返回的情况。
-- 未学习、已经就绪、只有公共冷却时统一返回0。
function Cat2.GetSpellIndependentCooldown(spell)
	local spellId = Cat2.GetSpellID(spell)
	if not spellId or spellId == 0 then
		return 0
	end

	local startTime, duration = GetSpellCooldown(spellId, "spell")
	if not startTime or not duration or duration <= 0 then
		return 0
	end

	local gcdMaximum = Cat2.GCDMax and Cat2.GCDMax() or 0
	if gcdMaximum > 0 and duration <= gcdMaximum + 0.2 then
		return 0
	end

	local remaining = duration - (GetTime() - startTime)
	if remaining < 0 then
		remaining = 0
	end
	return remaining
end

-- 技能是否处于自身的真实冷却中；公共冷却不算。
function Cat2.SpellOnCooldown(spell)
	return Cat2.GetSpellIndependentCooldown(spell) > 0
end

-- 获取技能是否存在
-- name技能名称
-- return 获取成立返id
-- 技能书运行时索引。技能书位置本身会在学习技能、洗天赋等操作后变化，
-- 因此只缓存“技能名称 -> 当前技能书位置”，冷却时间仍然每次向游戏 API 查询。
local spellBookCache = {
	dirty = true,
	firstByName = {},
	byNameAndRank = {},
	highestByName = {},
}

-- 事件回调只负责标脏；下一次真正查询技能时再统一扫描，避免连续事件重复重建。
function Cat2.InvalidateSpellBookCache()
	spellBookCache.dirty = true
end

-- 1.12/Turtle ??????????????????????????????????????????
-- ??????????????????????????????????????????????????????
local maximumSpellBookEntries = 300

local function RebuildSpellBookCache()
	local firstByName = {}
	local byNameAndRank = {}
	local highestByName = {}
	local spellIndex = 1

	while spellIndex <= maximumSpellBookEntries do
		local spellName, spellRank = GetSpellName(spellIndex, "spell")
		if not spellName or spellName == "" then
			break
		end

		-- GetSpellID(name) 原先返回从前往后遇到的第一个位置，继续保持该契约。
		if not firstByName[spellName] then
			firstByName[spellName] = spellIndex
		end

		if spellRank ~= nil then
			local ranks = byNameAndRank[spellName]
			if not ranks then
				ranks = {}
				byNameAndRank[spellName] = ranks
			end
			-- 理论上同名同等级不会重复；保留首项可兼容旧版顺序行为。
			if ranks[spellRank] == nil then
				ranks[spellRank] = spellIndex
			end
		end

		local rankNumber = 1
		if spellRank and spellRank ~= "" then
			local _, _, rankText = string.find(spellRank, "(%d+)")
			if rankText then
				rankNumber = tonumber(rankText) or 1
			end
		end
		local highest = highestByName[spellName]
		if not highest or rankNumber > highest.rank then
			highestByName[spellName] = {
				rank = rankNumber,
				index = spellIndex,
				rankText = spellRank,
			}
		end

		spellIndex = spellIndex + 1
	end

	spellBookCache.firstByName = firstByName
	spellBookCache.byNameAndRank = byNameAndRank
	spellBookCache.highestByName = highestByName
	-- 若调用发生得过早、技能书尚未就绪，则保持脏状态，避免永久缓存一份空技能书。
	spellBookCache.dirty = spellIndex == 1
end

local function EnsureSpellBookCache()
	if spellBookCache.dirty then
		RebuildSpellBookCache()
	end
end

function Cat2.GetSpellID(name, rank)
	if name == nil then
		return 0
	end
	name = Cat2.L.Spell(name)
	if rank ~= nil then
		rank = Cat2.L.Rank(rank)
	end
	EnsureSpellBookCache()
	if rank ~= nil then
		local ranks = spellBookCache.byNameAndRank[name]
		return ranks and ranks[rank] or 0
	end
	return spellBookCache.firstByName[name] or 0
end


------------------------
-- 施法
------------------------

function Cat2.CastSpellWithoutTarget(spellName, unit, tip)

	tip = tip or 0;

	if not unit then
		return false
	end

	-- record the real cast unit so the interrupt monitor can resolve it later
	if Cat2.RecordPendingCastTarget then
		Cat2.RecordPendingCastTarget(spellName, unit)
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
	if Cat2.GetChanneled() < 0.08 then
		-- record channeled spell names so the cursor / interrupt monitors can resolve them
		if Cat2.RecordWarlockChannelCast then
			Cat2.RecordWarlockChannelCast(spellName)
		end
		if Cat2.RecordMageChannelCast then
			Cat2.RecordMageChannelCast(spellName)
		end

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
end

-- 临时启用鼠标地面快速施法；恢复设置后再向框架传播错误。
function Cat2.WithCursorQuickcast(action, disableTargetQueue)
    local settings = { { "NP_QuickcastTargetingSpells", "1" } }
    if disableTargetQueue then
        table.insert(settings, { "NP_QueueTargetingSpells", "0" })
    end
    for _, setting in ipairs(settings) do
        local ok, value = pcall(GetCVar, setting[1])
        if not ok or (value ~= "0" and value ~= "1") then
            return false
        end
        setting[3] = value
    end

    local ok, result = pcall(function()
        for _, setting in ipairs(settings) do
            SetCVar(setting[1], setting[2])
        end
        return action()
    end)
    local restoreError
    for i = table.getn(settings), 1, -1 do
        local restored, message = pcall(SetCVar, settings[i][1], settings[i][3])
        if not restored then
            restoreError = message
        end
    end
    if restoreError then
        error(restoreError, 0)
    end
    if not ok then
        error(result, 0)
    end
    return result
end

function Cat2.CastWithNampower(spellName, unit)
	if Cat2.Nampower then
		QueueSpellByName(Cat2.L.Spell(spellName))
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
		QueueSpellByName(Cat2.L.Spell(spellName))
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


-- 按名称检查当前是否处于指定姿态或形态
function Cat2.GetShapeByName(shapename)
	if not shapename then
		return false
	end

	shapename = Cat2.L.Spell(shapename)

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
	itemName = Cat2.L.Item(itemName)
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
	itemName = Cat2.L.Item(itemName)
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
	itemName = Cat2.L.Item(itemName)
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
	itemName = Cat2.L.Item(itemName)
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
	itemName = Cat2.L.Item(itemName)
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

local function IsBankOpen()
    return (BankFrame and BankFrame:IsVisible()) or false
end

local function IsAuctionHouseOpen()
    return (AuctionFrame and AuctionFrame:IsVisible()) or false
end

local function IsMailboxOpen()
    return (MailFrame and MailFrame:IsVisible()) or false
end

local function IsMerchantOpen()
    return (MerchantFrame and MerchantFrame:IsVisible()) or false
end

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

-- 在公共冷却前半段尝试切换萨满图腾圣物。
-- 换装结果不负责阻断流程；context 标记只用于避免同一轮后续技能卡再次覆盖图腾。
function Cat2.TryEquipShamanTotem(context, itemName)
    if type(itemName) ~= "string" or itemName == "" then
        return false
    end
    if type(context) == "table" and context.shamanTotemSwitchHandled then
        return false
    end
    if not Cat2.IsGCDInFirstHalf or not Cat2.IsGCDInFirstHalf() or Cat2.CheckUIStatus() then
        return false
    end

    if Cat2.CheckInventoryItemName(18, itemName) then
        if type(context) == "table" then
            context.shamanTotemSwitchHandled = true
        end
        return false
    end

    if Cat2.EquipItemByName(itemName, 18) then
        if type(context) == "table" then
            context.shamanTotemSwitchHandled = true
        end
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
        line = getglobal("Cat2SpellTooltipTextRight" .. i)
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
	if spellName == nil then
		return 0, nil
	end
	spellName = Cat2.L.Spell(spellName)
	EnsureSpellBookCache()
	local highest = spellBookCache.highestByName[spellName]
	if not highest then
		return 0, nil
	end
	return highest.rank, highest.index
end

-- 根据参数解析技能书中实际可用的施法名称。
-- 无等级技能始终返回原始名称；有等级技能会限制在当前已学习的最高等级内。
function Cat2.GetRankedSpellName(spellName, requestedRank)
	if spellName == nil then
		return nil
	end
	spellName = Cat2.L.Spell(spellName)
	EnsureSpellBookCache()
	local highest = spellBookCache.highestByName[spellName]
	if not highest then
		return nil
	end

	-- 旧版客户端对无等级技能不能附加“(等级 1)”。
	if highest.rankText == nil or highest.rankText == "" then
		return spellName
	end

	local rankNumber = tonumber(requestedRank) or highest.rank
	rankNumber = math.floor(rankNumber + 0.5)
	if rankNumber < 1 then
		rankNumber = 1
	elseif rankNumber > highest.rank then
		rankNumber = highest.rank
	end

	local ranks = spellBookCache.byNameAndRank[spellName]
	if ranks then
		for rankText in pairs(ranks) do
			local _, _, numericText = string.find(rankText, "(%d+)")
			if numericText and tonumber(numericText) == rankNumber then
				return spellName .. "(" .. rankText .. ")"
			end
		end
	end

	-- 技能书异常缺少中间等级时，退回当前最高已学习等级。
	return spellName .. "(" .. highest.rankText .. ")"
end

function Cat2.CastRankedWithNampower(spellName, requestedRank)
	local rankedSpellName = Cat2.GetRankedSpellName(spellName, requestedRank)
	if not rankedSpellName then
		return false
	end
	Cat2.CastWithNampower(rankedSpellName)
	return true
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
                    local healingValue = Cat2.Match(text, Cat2.L("治疗效果，效果最多(%d+)点"))
                    if healingValue then
                        totalHealing = totalHealing + Cat2.ToNumber(healingValue)
                    end

					healingValue = Cat2.Match(text, Cat2.L("治疗效果提高最多(%d+)"))
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
        return itemType == Cat2.L("盾牌")
    end
    
    return false
end

-- 判定主手武器类型是匕首
function Cat2.IsMainHandDagger()
    local itemLink = GetInventoryItemLink("player", 16)
    local itemID = Cat2.Match(itemLink, "item:(%d+):")
    if itemLink then
        local _, _, _, _, _, itemType = GetItemInfo(itemID)
        return itemType == Cat2.L("匕首")  -- 注意：英文可能是"Dagger" or "Daggers" 
    end
    
    return false
end

-- 返回主手武器类型
function Cat2.GetMainHandType()
    local itemLink = GetInventoryItemLink("player", 16)
    local itemID = Cat2.Match(itemLink, "item:(%d+):")
    if itemLink then
        local _, _, _, _, _, itemType = GetItemInfo(itemID)
        return itemType
    end
    
    return nil
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

-- 远程栏是否装备投掷武器。
-- 不同 1.12 客户端扩展的物品类型字段位置可能不同，因此同时兼容第5、6、7返回值。
function Cat2.IsRangedThrownWeapon()
    local itemLink = GetInventoryItemLink("player", 18)  -- 18=远程武器栏位
    if not itemLink then return false end

	local itemID = Cat2.Match(itemLink, "item:(%d+):")
    if not itemID then return false end

	local _, _, _, _, value5, value6, value7 = GetItemInfo(Cat2.ToNumber(itemID))
	return value5 == Cat2.L("投掷武器") or value6 == Cat2.L("投掷武器") or value7 == Cat2.L("投掷武器")
end

-- 保留旧全局入口，避免仍在使用旧函数名的外部调用失效。
function IsRangedThrownWeapon()
	return Cat2.IsRangedThrownWeapon()
end



-- 检查身上装备格子的装备名称
function Cat2.CheckInventoryItemName(slot, name)
	local Link = GetInventoryItemLink("player",slot)
	if Link and strfind(Link,name) then return true end
	local localizedName = Cat2.L.Item(name)
	if localizedName ~= name and Link and strfind(Link,localizedName) then return true end
	return false
end

-- 爆发饰品白名单，迁移自旧 Cat 的 MPCheckTrinket；栏位13为上饰品，14为下饰品。
local burstTrinketNames = {
	"压制能量遗物",
	"狂野魔法宝石",
	"衰落之眼",
	"萨菲隆的精华",
	"屠龙者的纹章",
	"蜘蛛之吻",
	"偏斜雕文",
	"虫群卫士徽章",
	"沙漠掠夺者塑像",
	"沙虫之毒",
	"坠落星辰碎片",
	"自然之盟水晶",
	"盲目光芒卷轴",
	"毒性图腾",
	"思维加速宝石",
	"奥术能量宝石",
	"黑龙之书",
	"短暂能量护符",
	"焰烬之石",
	"赞达拉英雄勋章",
	"赞达拉英雄护符",
	"哈扎拉尔的魔法护符",
	"大地之击",
	"钻石水瓶",
	"优越护符",
	"龙人能量徽章",
	"魔暴龙眼",
}

function Cat2.IsBurstTrinket(slot)
	if slot ~= 13 and slot ~= 14 then
		return false
	end
	local index = 1
	local total = table.getn(burstTrinketNames)
	while index <= total do
		if Cat2.CheckInventoryItemName(slot, burstTrinketNames[index]) then
			return true
		end
		index = index + 1
	end
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
        if string.find(str,Cat2.L("替换")) then
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


-- 轻量仇恨兼容入口；保留旧函数名，避免现有卡片批量改调用点。
function Cat2.GetHatredFromTWT()
	if CatThreatLite and type(CatThreatLite.GetPercent) == "function" then
		local percent = CatThreatLite.GetPercent()
		if percent ~= nil then
			return math.floor(percent + 0.5)
		end
	end
	return -1

end







