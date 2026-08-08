-- Cat针对免疫各种属性库
Cat2 = Cat2 or {}

--- 检验单位能否流血
--- unit对象，默认为目标
--- return boolean can 能流血返回真，否则返回假
local monsterBlockList = {

    -- 木喉
    ["裂地者欧曼诺斯"] = true,
    ["欧曼诺斯的颤岩"] = true,

	-- K40
    ["地狱之怒碎片"] = true,
    ["噩梦爬行者"] = true,
    ["麦迪文的回响"] = true,
    ["恶魔之心"] = true,
    ["战争使者监军"] = true,
    ["兵卒"] = true,
    ["共鸣水晶"] = true,
    ["徘徊的魔法师"] = true,
    ["徘徊的占星家"] = true,
    ["徘徊的魔术师"] = true,
    ["徘徊的工匠"] = true,
    ["鬼灵训练师"] = true,
    ["荒芜的入侵者"] = true,

	-- 卡拉赞下层
    ["幻影守卫"] = true,
    ["幽灵厨师"] = true,
    ["闹鬼铁匠"] = true,
    ["幻影仆从"] = true,
    ["莫罗斯"] = true,

	-- NAXX
    ["瘟疫战士"] = true,
    ["白骨构造体"] = true,
    ["邪恶之斧"] = true,
    ["邪恶法杖"] = true,
    ["邪恶之剑"] = true,
    ["纳克萨玛斯之魂"] = true,
    ["纳克萨玛斯之影"] = true,
    ["憎恨吟唱者"] = true,
    ["死灵骑士"] = true,
    ["死灵骑士卫兵"] = true,
    ["骷髅骏马"] = true,

	-- TAQ

    -- 黑龙
    ["奥妮克希亚火嗣"] = true,

    -- FX
    ["莫阿姆"] = true,

	-- MC
    ["熔核巨人"] = true,
    ["暗炉卫士"] = true,
    ["暗炉织焰者"] = true,
    ["暗炉圣职者"] = true,
    ["法师领主索瑞森"] = true,
    ["巫王索瑞森"] = true,
    ["熔核摧毁者"] = true,

	-- STSM
    ["安娜丝塔丽男爵夫人"] = true,
    ["埃提耶什"] = true,

    -- 龙吼居所
    ["被遗忘的先祖"] = true,
    ["哈尔甘·红标"] = true,

    -- 黑石深渊
    ["弗莱拉斯大使"] = true,
    ["安格雷尔"] = true,
    ["西斯雷尔"] = true,
    ["多普雷尔"] = true,
    ["格鲁雷尔"] = true,
    ["瓦勒雷尔"] = true,
    ["黑特雷尔"] = true,
    ["杜姆雷尔"] = true,
    ["玛格姆斯"] = true,

	-- 玛拉顿
    ["瑟莱德丝公主"] = true,

	-- 暴风城地牢
    ["戴米安"] = true,

	-- 其他
    ["黑衣守卫斥候"] = true,
    ["哀嚎的女妖"] = true,
    ["尖叫的女妖"] = true,
    ["无眼观察者"] = true,
    ["黑暗法师"] = true,
    ["幽灵训练师"] = true,
    ["受难的上层精灵"] = true,
    ["死亡歌手"] = true,
    ["恐怖编织者"] = true,
    ["哀嚎的死者"] = true,
    ["亡鬼幻象"] = true,
    ["恐惧骸骨"] = true,
    ["骷髅刽子手"] = true,
    ["骷髅剥皮者"] = true,
    ["骷髅守护者"] = true,
    ["骷髅巫师"] = true,
    ["骷髅军官"] = true,
    ["骷髅侍僧"] = true,
    ["游荡的骷髅"] = true,
    ["骷髅铁匠"] = true,
    ["鬼魅随从"] = true,
    ["艾德雷斯妖灵"] = true,
    ["天灾勇士"] = true,
    ["天灾卫兵"] = true,
    ["不安宁的阴影"] = true,
    ["不死的看守者"] = true,
    ["哀嚎的鬼怪"] = true,
    ["被诅咒的灵魂"] = true,
    ["不死的居民"] = true,
    ["不死的看守者"] = true,
    ["幽灵工人"] = true,
    ["鬼灵工人"] = true,
    ["徘徊的农夫"] = true,
    ["被诅咒的水兵"] = true,
    ["峭壁咆哮者"] = true,
    ["峭壁行者"] = true,
    ["峭壁击碎者"] = true,
}

-- 元素生物,机械中的白名单列表
local monsterWhiteList = {

	-- K40
    ["失控的骑士"] = true,

	-- MC
    ["加尔"] = true,
    ["焚化者古雷曼格"] = true,
    ["巴萨尔萨"] = true,
    ["斯摩达利斯"] = true,

	-- 玛拉顿
	["锐刺鞭笞者"] = true,

	-- World
    ["灌木塑根者"] = true,
    ["灌木露水收集者"] = true,
    ["长瘤的灌木兽"] = true,
    ["焦油潜伏者"] = true,
    ["焦油爬行者"] = true,
    ["焦油兽王"] = true,
    ["焦油兽"] = true,
}

function Cat2.CanBleed(unit)
	unit = unit or "target"
	local name = UnitName(unit)

	if not name then
		return false
	end

	-- 元素生物,机械，直接认定为不可流血
	local creature = UnitCreatureType(unit) or "其它"
	local position = string.find("元素生物,机械", creature)
	if position then
		-- 元素生物与机械中的白名单
		if monsterWhiteList[name] == true then
			return true
		end
		return false
	end

	-- 判断怪物名单
	if monsterBlockList[name] == true then
		return false
	end

	return true
end

--- 检验单位是否为BOSS级别
--- return boolean can 返回真，否则返回假
function Cat2.IsBossTarget()
    if not UnitExists("target") then return false end
    
    -- 检查精英标志(骷髅级)
    if UnitClassification("target") == "worldboss" or 
       UnitClassification("target") == "rareelite" then
        return true
    end
    
    -- 检查血量（普通BOSS通常血量远高于玩家）
    local healthMax = UnitHealthMax("target")
    if healthMax > 300000 then
        return true
    end
    
    -- 检查已知BOSS名字
    local bossList = {
        ["克尔苏加德"] = true,
        ["拉格纳罗斯"] = true,
    }
    if bossList[UnitName("target")] then
        return true
    end
    
    return false
end



-- 吸血黑名单
local drainBlockList = {
	-- TAQ
    ["维克洛尔大帝"] = true,
    ["维克尼拉斯大帝"] = true,

	-- test
    --["学徒训练假人"] = true,
}

-- 检测单位是否可以吸血
--- return boolean can 返回真，否则返回假
function Cat2.IsDrain(unit)
	unit = unit or "target"
	local name = UnitName(unit)

	if not name then
		return false
	end

	-- 机械，直接认定为不可吸血
	local creature = UnitCreatureType(unit) or "其它"
	local position = string.find("机械", creature)
	if position then
		return false
	end

	-- 判断怪物名单
	if drainBlockList[name] == true then
		return false
	end

	return true
end


local poisonBlockList = {
	-- TAQ
    ["维克洛尔大帝"] = true,
    ["维克尼拉斯大帝"] = true,

    -- 世界

}

-- 检测单位是否可以中毒
--- return boolean can 返回真，否则返回假
function Cat2.IsPoison(unit)
	unit = unit or "target"

	-- 机械、元素，直接认定为不可中毒
	local creature = UnitCreatureType(unit) or "其它"
	local position = string.find("元素生物,机械", creature)
	if position then
		return false
	end

	-- 判断不吃毒名单
	local name = UnitName(unit)
	if poisonBlockList[name] == true then
		return false
	end

	return true
end



-- 精灵之火黑名单
local faerieFireBlockList = {

    -- 木喉
    ["被污染的胶团"] = true,

	-- NAXX
    ["鬼灵训练师"] = true,
    ["鬼灵坐骑"] = true,
    ["鬼灵骑兵"] = true,

	-- TAQ
    ["维克洛尔大帝"] = true,
    ["维克尼拉斯大帝"] = true,

    -- BWL
    ["黑翼缚法者"] = true,

	-- 神庙
    ["德拉维沃尔"] = true,

	-- 世界BOSS
    ["桑德兰王子"] = true,

    -- 世界
    ["熔岩元素"] = true,
    ["涅玛丝拉"] = true,
    ["雷霆流放者"] = true,
    ["狂风漩涡"] = true,

    -- 黑石深渊
    ["达格兰·索瑞森大帝"] = true,

	-- test
    --["学徒训练假人"] = true,
}

-- 检测单位是否吃精灵之火
--- return boolean can 返回真，否则返回假
function Cat2.IsFaerieFire(unit)
	unit = unit or "target"
	local name = UnitName(unit)

	if not name then
		return false
	end

	-- 判断精灵之火名单
	if faerieFireBlockList[name] == true then
		return false
	end

	return true
end





--- 检验单位是否为BOSS级别
--- return boolean can 返回真，否则返回假
function Cat2.IsBossTarget()
    if not Cat2.PlayerInformation.temporary.targetExists then return false end
    
    -- 检查精英标志(骷髅级)
    if Cat2.PlayerInformation.temporary.targetClassification == "worldboss" or 
       Cat2.PlayerInformation.temporary.targetClassification == "rareelite" then
        return true
    end
    
    -- 检查血量（普通BOSS通常血量远高于玩家）
    if Cat2.PlayerInformation.temporary.targetHealth > 280000 then
        return true
    end
    
    -- 检查已知BOSS名字
    local bossList = {
        ["克尔苏加德"] = true,
        ["拉格纳罗斯"] = true,
    }
    if bossList[Cat2.PlayerInformation.temporary.targetName] then
        return true
    end
    
    return false
end

