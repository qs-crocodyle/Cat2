-- Cat2 Buff 与 Debuff 查询库。
-- 通过隐藏 GameTooltip 读取旧客户端 API 未直接提供的名称、层数与持续时间信息。
-- 卡片应调用本文件公开的 Cat2 函数，不要直接依赖隐藏 Tooltip 的全局名称。
_G = getfenv()
Cat2 = Cat2 or {}


local Cat2GetBuffTooltip = CreateFrame("GameTooltip", "Cat2GetBuffTooltip", UIParent, "GameTooltipTemplate")


-- 内部调用
function Cat2.GetBuffNameByIndex(unit, index)

	Cat2GetBuffTooltip:ClearLines()
	Cat2GetBuffTooltip:SetUnitBuff(unit, index)
	local buffName = Cat2GetBuffTooltipTextLeft1:GetText()

	if buffName then
		return true, buffName
	end

	return false, "未发现BUFF"
end

-- 内部调用
function Cat2.GetDebuffNameByIndex(unit, index)

	Cat2GetBuffTooltip:ClearLines()
	Cat2GetBuffTooltip:SetUnitDebuff(unit, index)
	local buffName = Cat2GetBuffTooltipTextLeft1:GetText()

	if buffName then
		return true, buffName
	end

	return false, "未发现BUFF"
end



-- 查找 Aura（BUFF 或 DEBUFF）并返回可能的时间，-1为未找到
function Cat2.BuffTime(buffName, unit)
	unit = unit or "player";  -- 默认检查玩家自己

	-- 提取buff的index client显示
	Cat2GetBuffTooltip:SetOwner(UIParent, "ANCHOR_NONE")

	local i = 1
	for i = 0, 32 do
		Cat2GetBuffTooltip:ClearLines()
		Cat2GetBuffTooltip:SetPlayerBuff(i)
		--print(i,Cat2GetBuffTooltipTextLeft1:GetText())
		if Cat2GetBuffTooltipTextLeft1:GetText() == buffName then
			return GetPlayerBuffTimeLeft(i)
		end
	end

	return 0
end


function Cat2.BuffTimeFromTex(buffIcon)
	unit = "player"

	-- 提取buff的index
	for i = 0, 32 do

		-- 通过索引尝试访问buff
		local indexTex = GetPlayerBuffTexture(i)
		if not indexTex then
			break
		end

		-- 校验图标
		if indexTex == buffIcon then
			local timeleft = GetPlayerBuffTimeLeft(i)
			if timeleft>0 then
				return timeleft
			end
		end

	end

	return -1
end



-- 查找 Aura（BUFF 或 DEBUFF）并返回 (found, index)
-- @param targetName: 要查找的 Aura 名称（如 "真言术：盾"、"中毒"）
-- @param unit: 目标单位（默认为 "player"）
-- 支持SuperWoW
function Cat2.Buff(buffName, unit)

	unit = unit or "player"  -- 默认检查玩家自己
	Cat2GetBuffTooltip:SetOwner(UIParent, "ANCHOR_NONE")

	-- 扫描debuff位
	local i = 1
	while UnitDebuff(unit, i) do
		-- 通过索引尝试访问buff
		local found, name = Cat2.GetDebuffNameByIndex(unit,i)
		if found then
			-- 找到buff，并名称正确
			if name==buffName then
				return true, i
			end
		end
		i = i + 1
	end

	-- 扫描buff位
	i = 1
	while UnitBuff(unit, i) do
		-- 通过索引尝试访问buff
		local found, name = Cat2.GetBuffNameByIndex(unit,i)
		if found then
			-- 找到buff，并名称正确
			if name==buffName then
				return true, i
			end
		end
		i = i + 1
	end


    return false, -1  -- 未找到
end


-- 一次扫描指定单位身上的全部 Buff 和 Debuff，并返回名称集合。
-- 列表只代表创建它时的 Aura 状态；进入下一次技能判断时应重新创建。
--
-- local list = Cat2.BuffList("target")
-- if list["精灵之火"] then
--     ...
-- end
function Cat2.BuffList(unit)
	unit = unit or "player"
	local list = {}
	local i = 1
	Cat2GetBuffTooltip:SetOwner(UIParent, "ANCHOR_NONE")

	while true do
		local found, name = Cat2.GetDebuffNameByIndex(unit, i)
		if not found then
			break
		end
		list[name] = true
		i = i + 1
	end

	i = 1
	while true do
		local found, name = Cat2.GetBuffNameByIndex(unit, i)
		if not found then
			break
		end
		list[name] = true
		i = i + 1
	end

	return list
end


-- 取消自己身上的buff
-- @param buffName: 要取消的Buff名称（如 "野性印记"、"恢复"）
function Cat2.CancelBuffByName(buffName)

	Cat2GetBuffTooltip:SetOwner(UIParent, "ANCHOR_NONE")

	local i = 1
	for i = 0, 32 do
		Cat2GetBuffTooltip:ClearLines()
		Cat2GetBuffTooltip:SetPlayerBuff(i)
		--print(i,Cat2GetBuffTooltipTextLeft1:GetText())
		if Cat2GetBuffTooltipTextLeft1:GetText() == buffName then
			CancelPlayerBuff(i)
			return
		end
	end
	--[[
	unit = unit or "player";  -- 默认检查玩家自己
	local f, i = Cat2.Buff(buffName, unit)
	if f then
		if i ~= -1 then
			CancelPlayerBuff(i)
		end
	end
	]]
end

-- 获取buff层数
function Cat2.GetBuffLevel(buffName, unit)
	unit = unit or "player";  -- 默认检查玩家自己

	local f, i = Cat2.Buff(buffName, unit)
	if not f then
		return 0
	end

	local bufft,bufflevel = UnitBuff(unit,i)

	if bufft then
		return bufflevel
	end

	return 0
end

-- 获取debuff层数
function Cat2.GetDebuffLevel(buffName, unit)
	unit = unit or "player";  -- 默认检查玩家自己

	local f, i = Cat2.Buff(buffName, unit)
	if not f then
		return 0
	end

	bufft,bufflevel = UnitDebuff(unit,i)

	if bufft then
		return bufflevel
	end

	return 0
end

-- 获取debuff类型
--  "Magic", "Curse", "Poison", "Disease"
function Cat2.IsDebuffType(type, unit)
	unit = unit or "player";  -- 默认检查玩家自己

	for i = 1, 16 do
		local bufft,bufflevel,bufftype = UnitDebuff(unit,i)
		if bufftype==type then
			return true
		end
	end

	return false
end


function Cat2.GetTexFromBuff(index, unit)
	unit = unit or "player";  -- 默认检查玩家自己

	local bufft,bufflevel = UnitBuff(unit,index)
	if bufft then
		return bufft
	end

	return nil
end


function Cat2.BuffFromTex(buffIcon, unit)
	unit = unit or "player";  -- 默认检查玩家自己

	for i = 1, 32 do
		bufft,bufflevel = UnitBuff(unit,i)
		if bufft and bufft==buffIcon then
			return true
		end
	end

	for i = 1, 64 do
		bufft,bufflevel = UnitDebuff(unit,i)
		if bufft and bufft==buffIcon then
			return true
		end
	end

	return false
end

-- 获取buff层数，通过图标
function Cat2.GetBuffApplications(buffIcon, unit)
	unit = unit or "player";  -- 默认检查玩家自己


	for i = 1, 64 do
		bufft,bufflevel = UnitBuff(unit,i)
		if bufft and bufft==buffIcon then
			--message(unit.." index: "..i.."   texture: "..bufft)
			return bufflevel
		end
	end
	for i = 1, 64 do
		debufft,debufflevel = UnitDebuff(unit,i)
		if debufft and debufft==buffIcon then
			--message(unit.." index: "..i.."   texture: "..bufft)
			return debufflevel
		end
	end

	return 0
end

-- 获取debuff层数，通过图标
function Cat2.GetDebuffApplications(buffIcon, unit)
	unit = unit or "player";  -- 默认检查玩家自己

	for i = 1, 64 do
		bufft,bufflevel = UnitDebuff(unit,i)
		if bufft and bufft==buffIcon then
			--message(unit.." index: "..i.."   texture: "..bufft)
			return bufflevel
		end
	end

	return 0
end


-- 保持自己身上的buff
function Cat2.HoldBuff(buffName)
	if buffName and not Cat2.Buff(buffName) then
		CastSpellByName(buffName)
	end
end








