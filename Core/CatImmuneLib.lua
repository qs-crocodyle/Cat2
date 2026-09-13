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

    -- ZG
    ["古拉巴什狂暴者"] = true,

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

    -- 生物免疫第三弹l.xlsx：流血控制免疫
    ["阿兰齐斯"] = true,
    ["阿塔莱骷髅"] = true,
    ["阿塔莱死亡行者的灵魂"] = true,
    ["哀嚎的鬼魂"] = true,
    ["哀嚎的贵族"] = true,
    ["哀嚎的卫兵"] = true,
    ["艾德雷斯鬼怪"] = true,
    ["艾隆纳亚"] = true,
    ["艾鲁拉的阴影"] = true,
    ["艾萨莱斯特"] = true,
    ["安娜雅·晨路"] = true,
    ["暗牙恐狼"] = true,
    ["暗眼骷髅法师"] = true,
    ["奥芬利亚·蒙泰古"] = true,
    ["奥伦提尔"] = true,
    ["巴尔萨冯"] = true,
    ["被遗忘者军马"] = true,
    ["被折磨的德鲁伊"] = true,
    ["被折磨的奴隶"] = true,
    ["被折磨的哨兵"] = true,
    ["被诅咒的贵族"] = true,
    ["被诅咒的审判者"] = true,
    ["被诅咒的圣骑士"] = true,
    ["被诅咒的水手"] = true,
    ["变异鞭笞者"] = true,
    ["冰冻之魂"] = true,
    ["冰霜亡魂"] = true,
    ["不可宽恕者"] = true,
    ["步行炸弹"] = true,
    ["部落医师"] = true,
    ["陈腐之灵"] = true,
    ["触须传送门"] = true,
    ["脆弱的骷髅"] = true,
    ["达高尔队长"] = true,
    ["达隆郡背叛者"] = true,
    ["达隆郡恶鬼"] = true,
    ["达隆郡防御者"] = true,
    ["达隆郡居民的灵魂"] = true,
    ["大元素师克里希克"] = true,
    ["代弗林·阿加曼德"] = true,
    ["胆汁呕吐者"] = true,
    ["冬季驯鹿"] = true,
    ["冬天爷爷的助手"] = true,
    ["断骨骷髅"] = true,
    ["断骨士兵"] = true,
    ["多彩龙兽"] = true,
    ["堕落的雷德帕斯"] = true,
    ["堕落风怒图腾 III"] = true,
    ["堕落火焰新星图腾 V"] = true,
    ["堕落石肤图腾 VI"] = true,
    ["堕落治疗之泉图腾 V"] = true,
    ["恶心的软泥怪"] = true,
    ["发条机器人"] = true,
    ["法瑟蕾丝夫人"] = true,
    ["防护元素图腾"] = true,
    ["菲林森特的阴影"] = true,
    ["缝补傀儡"] = true,
    ["缝合呕吐者"] = true,
    ["复仇的幻影"] = true,
    ["复活的保卫者"] = true,
    ["复活的构造体"] = true,
    ["复活的畸形骷髅"] = true,
    ["复活的骷髅守卫"] = true,
    ["复活的侍从"] = true,
    ["复活的守护者"] = true,
    ["复活的卫兵"] = true,
    ["复活的战士"] = true,
    ["古拉巴什"] = true,
    ["骨巫"] = true,
    ["鬼怪仆从"] = true,
    ["鬼魂市民"] = true,
    ["鬼灵背叛者"] = true,
    ["鬼灵导师"] = true,
    ["鬼灵幻象"] = true,
    ["鬼灵幻影"] = true,
    ["鬼灵教师"] = true,
    ["鬼灵掠夺者"] = true,
    ["鬼灵士兵"] = true,
    ["鬼灵研究员"] = true,
    ["鬼灵之魂"] = true,
    ["鬼魅防御者"] = true,
    ["鬼魅幻影"] = true,
    ["鬼魅掠夺者"] = true,
    ["鬼魅尸体"] = true,
    ["鬼魅袭击者"] = true,
    ["哈林多尔船长"] = true,
    ["骸骨魔"] = true,
    ["骸骨魔(暴怒状态)"] = true,
    ["寒冰鬼魂"] = true,
    ["寒冰之灵"] = true,
    ["赫尔库拉的傀儡"] = true,
    ["黑暗镰刀"] = true,
    ["黑暗之影"] = true,
    ["黑色骸骨战马"] = true,
    ["黑衣守卫铸剑师"] = true,
    ["红色骸骨军马"] = true,
    ["红色骷髅战马"] = true,
    ["护锅者拉扎奇"] = true,
    ["护锅者玛维诺斯"] = true,
    ["护锅者索瓦斯"] = true,
    ["怀恨的幻影"] = true,
    ["幻象之影"] = true,
    ["饥饿的鬼魂"] = true,
    ["机械松鼠"] = true,
    ["机械小鸡"] = true,
    ["加里杨"] = true,
    ["尖刺鞭笞者"] = true,
    ["巨型触须传送门"] = true,
    ["科多之魂"] = true,
    ["可憎的阿拉杜斯"] = true,
    ["恐怖骸骨"] = true,
    ["恐惧谷的灵魂"] = true,
    ["骷髅"] = true,
    ["骷髅暗影法师"] = true,
    ["骷髅冰霜法师"] = true,
    ["骷髅步兵"] = true,
    ["骷髅法师"] = true,
    ["骷髅看守"] = true,
    ["骷髅狂战士"] = true,
    ["骷髅矿工"] = true,
    ["骷髅马"] = true,
    ["骷髅仆从"] = true,
    ["骷髅士兵"] = true,
    ["骷髅突击队员"] = true,
    ["骷髅袭击者"] = true,
    ["骷髅医师"] = true,
    ["骷髅战士"] = true,
    ["骷髅召唤者"] = true,
    ["狂怒的幻影"] = true,
    ["狂野的拉佐格尔"] = true,
    ["莱斯·霜语"] = true,
    ["蓝色骸骨军马"] = true,
    ["莉莉丝·奈法拉"] = true,
    ["联盟医师"] = true,
    ["烈焰行者护卫"] = true,
    ["烈焰震击者"] = true,
    ["绿色骷髅战马"] = true,
    ["罗瑞"] = true,
    ["洛丹伦平民"] = true,
    ["洛曼卡恩大使"] = true,
    ["玛格拉姆鬼魂"] = true,
    ["蟒藤"] = true,
    ["梦雾"] = true,
    ["摩拉迪姆"] = true,
    ["末日之影"] = true,
    ["莫嘉泽尔"] = true,
    ["暮光元素法师"] = true,
    ["纳克萨玛斯之眼"] = true,
    ["奈塔拉什"] = true,
    ["妮萨·阿加曼德"] = true,
    ["女妖之王"] = true,
    ["徘徊的上层精灵"] = true,
    ["珀月的阴影"] = true,
    ["破碎尖啸者"] = true,
    ["骑乘用骸骨战马（黑色）"] = true,
    ["弃灵"] = true,
    ["清洁者"] = true,
    ["屈服的纳萨诺斯之魂"] = true,
    ["锐刺鞭笞者"] = true,
    ["上层精灵的幻影"] = true,
    ["上层精灵鬼巫"] = true,
    ["上层精灵骷髅"] = true,
    ["上古之魂"] = true,
    ["审判者塞尔格拉姆"] = true,
    ["失落的灵魂"] = true,
    ["斯蒂芬·巴尔泰克"] = true,
    ["斯库尔"] = true,
    ["死亡之誓"] = true,
    ["肆虐的骷髅"] = true,
    ["碎骨百夫长"] = true,
    ["碎骨骷髅"] = true,
    ["碎骨统帅"] = true,
    ["碎骨战士"] = true,
    ["碎裂的骷髅"] = true,
    ["碎颅士兵"] = true,
    ["特雷·莱弗治的灵魂"] = true,
    ["天灾步兵"] = true,
    ["天灾弓箭手"] = true,
    ["天灾看守"] = true,
    ["天灾士兵"] = true,
    ["铁脊死灵"] = true,
    ["通灵学院骷髅学员"] = true,
    ["痛苦的沉睡者"] = true,
    ["痛苦的法师"] = true,
    ["痛苦的上层精灵"] = true,
    ["痛苦的文官"] = true,
    ["土灵管理者"] = true,
    ["土灵守护者"] = true,
    ["土灵筑厅师"] = true,
    ["瓦罗森的幽灵"] = true,
    ["万圣节男鬼魂"] = true,
    ["亡灵劫掠者"] = true,
    ["往日的幽灵"] = true,
    ["乌舍尔"] = true,
    ["无脑的骷髅"] = true,
    ["无脑的亡灵"] = true,
    ["无影仆从"] = true,
    ["希尔希克斯"] = true,
    ["鲜血鬼魂"] = true,
    ["辛迪加鬼魂"] = true,
    ["血瓣花鞭笞者"] = true,
    ["血瓣花捕兽者"] = true,
    ["血瓣花掠夺者"] = true,
    ["血瓣花猛击者"] = true,
    ["血肉触须"] = true,
    ["迅捷绿色骸骨军马"] = true,
    ["迅捷祖利安猛虎"] = true,
    ["鸦爪摄政者"] = true,
    ["鸦爪守护者"] = true,
    ["鸦爪袭击者"] = true,
    ["鸦爪勇士"] = true,
    ["鸦爪幽灵"] = true,
    ["鸦爪之手"] = true,
    ["野猪之魂"] = true,
    ["伊莉莎的卫兵"] = true,
    ["银色坐骑"] = true,
    ["隐迹鬼魂"] = true,
    ["英雄之魂"] = true,
    ["永醒的艾希尔"] = true,
    ["幽灵市民"] = true,
    ["有罪的牧师"] = true,
    ["有罪的僧侣"] = true,
    ["有罪的侍僧"] = true,
    ["淤泥喷射者"] = true,
    ["赞吉尔骷髅"] = true,
    ["召唤者阿拉基"] = true,
    ["挣扎的贵族"] = true,
    ["指挥官菲斯托姆"] = true,
    ["紫色骷髅战马"] = true,
    ["棕色骸骨军马"] = true,
    ["诅咒法师"] = true,
    ["诅咒者之魂"] = true,
    ["祖穆拉恩骷髅"] = true,
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

    -- 生物免疫第三弹l.xlsx：元素/机械但未标注流血免疫
    ["暗影碎片雷鸣者"] = true,
    ["奥术恶兽"] = true,
    ["暴风雪元素"] = true,
    ["暴雪守护者"] = true,
    ["苍白圣殿骑士"] = true,
    ["糙石元素"] = true,
    ["毒性掠夺者"] = true,
    ["毒性之水"] = true,
    ["堕落的水元素"] = true,
    ["法力元素"] = true,
    ["腐朽的树人"] = true,
    ["琥珀碎片暴怒者"] = true,
    ["机械陆行鸟"] = true,
    ["焦黑的石灵"] = true,
    ["枯萎的看守者"] = true,
    ["枯萎的森林行者"] = true,
    ["枯萎的守卫者"] = true,
    ["枯萎的树人"] = true,
    ["兰德雷萨公爵"] = true,
    ["烈焰元素"] = true,
    ["南海火炮"] = true,
    ["熔岩怪"] = true,
    ["塞拉摩箭靶 1"] = true,
    ["塞拉摩箭靶 2"] = true,
    ["塞拉摩训练假人 4"] = true,
    ["塞拉摩运输船"] = true,
    ["石头看守者"] = true,
    ["树人保卫者"] = true,
    ["塔纳利斯之魂"] = true,
    ["泰匹斯特"] = true,
    ["土色圣殿骑士"] = true,
    ["瘟疫兽"] = true,
    ["虚空鞭笞者"] = true,
    ["游荡岩石元素"] = true,
    ["蒸汽坦克"] = true,
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


-- 吸血黑名单
local ManaDrainBlockList = {
	-- TAQ
    ["维克洛尔大帝"] = true,
    ["维克尼拉斯大帝"] = true,

	-- test
    --["学徒训练假人"] = true,
}

-- 检测单位是否可以吸血
--- return boolean can 返回真，否则返回假
function Cat2.IsManaDrain(unit)
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

    -- 目标是否有蓝
    if UnitManaMax(unit) < 150 then
		return false
    end

	-- 判断怪物名单
	if ManaDrainBlockList[name] == true then
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

    -- ZG
    ["哈卡莱祭司"] = true,

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





-- 各伤害系的免疫名单。名单保持为模块局部数据，卡片统一通过下方接口查询。
-- 静态名单主要来自工作区“生物免疫第三弹l.xlsx”的 name_zh 与 damage_immune_zh 字段。
-- 注意：不能根据“机械”或“元素生物”类型直接推断自然免疫；不能中毒不等于免疫自然伤害。
local damageSchoolImmuneLists = {
    physical = {
        ["阿塔莱死亡行者的灵魂"] = true,
        ["黑暗之影"] = true,
    },
    holy = {
        ["阿塔莱死亡行者的灵魂"] = true,
    },
    fire = {
        ["阿塔莱死亡行者的灵魂"] = true,
        ["埃博诺克"] = true,
        ["奥妮克希亚"] = true,
        ["赤红圣殿骑士"] = true,
        ["炽热火焰卫士"] = true,
        ["炽热入侵者"] = true,
        ["炽热元素"] = true,
        ["次级地狱火"] = true,
        ["地狱火保镖"] = true,
        ["地狱火仆从"] = true,
        ["地狱火哨兵"] = true,
        ["地狱火爪牙"] = true,
        ["地狱元素"] = true,
        ["堕落地狱火"] = true,
        ["堕落的瓦拉斯塔兹"] = true,
        ["发怒的地狱火"] = true,
        ["费尔库拉"] = true,
        ["费尔默"] = true,
        ["弗莱格尔"] = true,
        ["鬼灵骑兵"] = true,
        ["鬼灵死亡骑士"] = true,
        ["鬼灵学徒"] = true,
        ["鬼灵战马"] = true,
        ["红色瘟疫软泥怪"] = true,
        ["灰烬元素"] = true,
        ["活火"] = true,
        ["火灵"] = true,
        ["火焰男爵查尔"] = true,
        ["火焰驱逐者"] = true,
        ["火焰使者"] = true,
        ["火焰卫士"] = true,
        ["火焰行者"] = true,
        ["火焰之魂"] = true,
        ["火焰之王"] = true,
        ["火元素"] = true,
        ["迦顿男爵"] = true,
        ["巨型地狱火"] = true,
        ["拉格纳罗斯"] = true,
        ["烈焰流放者"] = true,
        ["烈焰守卫"] = true,
        ["烈焰卫士艾博希尔"] = true,
        ["烈焰之子"] = true,
        ["纳克罗什酋长"] = true,
        ["奈法利安"] = true,
        ["燃灵术"] = true,
        ["燃烧的掠夺者"] = true,
        ["燃烧的破坏者"] = true,
        ["燃烧仆从"] = true,
        ["热能恐兽"] = true,
        ["热能野兽"] = true,
        ["熔岩爪牙"] = true,
        ["斯卡德诺克斯王子"] = true,
        ["斯卡尔德"] = true,
        ["吞噬者特雷姆斯"] = true,
        ["伊利法尔"] = true,
        ["伊森迪奥斯"] = true,
        ["因弗努斯大使"] = true,
        ["游荡的焰灵"] = true,
        ["有生烈焰"] = true,
        ["余烬"] = true,
        ["征服者派隆"] = true,
        ["灼热的地狱火"] = true,
        ["灼热元素"] = true,
    },
    nature = {
        ["阿塔莱死亡行者的灵魂"] = true,
        ["艾莫莉丝"] = true,
        ["奥术洪流"] = true,
        ["奥术回馈者"] = true,
        ["暴烈的石灵"] = true,
        ["尘魔"] = true,
        ["抽笞者"] = true,
        ["德拉维沃尔"] = true,
        ["风嚎者"] = true,
        ["鬼灵骑兵"] = true,
        ["鬼灵死亡骑士"] = true,
        ["鬼灵学徒"] = true,
        ["鬼灵战马"] = true,
        ["哈瑞坎尼安"] = true,
        ["灰尘风暴"] = true,
        ["活风暴"] = true,
        ["飓风战士"] = true,
        ["空气漩涡"] = true,
        ["空气之魂"] = true,
        ["狂风漩涡"] = true,
        ["狂怒的石灵"] = true,
        ["莱索恩"] = true,
        ["雷霆流放者"] = true,
        ["烈风掠夺者"] = true,
        ["绿色瘟疫软泥怪"] = true,
        ["熔岩领主博奥克"] = true,
        ["熔岩元素"] = true,
        ["塞克隆尼亚"] = true,
        ["桑德兰王子"] = true,
        ["斯莫达尔"] = true,
        ["泰拉尔"] = true,
        ["顽石流放者"] = true,
        ["旋风雷暴行者"] = true,
        ["旋风切割者"] = true,
        ["旋风入侵者"] = true,
        ["旋风撕裂者"] = true,
        ["伊森德雷"] = true,
    },
    frost = {
        ["阿库麦尔的仆从"] = true,
        ["阿奎尼斯男爵"] = true,
        ["阿塔莱死亡行者的灵魂"] = true,
        ["埃卡洛姆"] = true,
        ["被召唤的水元素"] = true,
        ["碧蓝圣殿骑士"] = true,
        ["次级水元素"] = true,
        ["堕落的水灵"] = true,
        ["堕落的水之魂"] = true,
        ["沸腾的水元素"] = true,
        ["费尔库拉"] = true,
        ["辐射水元素"] = true,
        ["复仇巨浪"] = true,
        ["鬼灵骑兵"] = true,
        ["鬼灵死亡骑士"] = true,
        ["鬼灵学徒"] = true,
        ["鬼灵战马"] = true,
        ["滚烫的水元素"] = true,
        ["海达克西斯公爵"] = true,
        ["海达克西斯禁卫"] = true,
        ["海多斯博恩"] = true,
        ["海元素"] = true,
        ["荒芜巨浪"] = true,
        ["荒芜水元素"] = true,
        ["灰色座狼"] = true,
        ["混乱巨浪"] = true,
        ["巨型海元素"] = true,
        ["剧毒之水"] = true,
        ["蓝色瘟疫软泥怪"] = true,
        ["泥浆元素"] = true,
        ["诺克赛恩"] = true,
        ["诺克赛恩产物"] = true,
        ["诺克赛恩精华"] = true,
        ["诺克赛恩幼体"] = true,
        ["萨菲隆"] = true,
        ["守护者"] = true,
        ["水魂"] = true,
        ["水浪流放者"] = true,
        ["水浪幼崽"] = true,
        ["水灵"] = true,
        ["水流入侵者"] = true,
        ["水元素"] = true,
        ["水之魂"] = true,
        ["水中护卫"] = true,
        ["斯古恩男爵"] = true,
        ["搜寻者埃库隆"] = true,
        ["苏纳曼"] = true,
        ["泰比斯蒂亚公主"] = true,
        ["泰德雷斯"] = true,
        ["瘟疫破坏者"] = true,
        ["瘟疫水元素"] = true,
        ["污浊的水元素"] = true,
        ["小型水元素护卫"] = true,
        ["亚奎门塔斯"] = true,
        ["伊利法尔"] = true,
        ["影牙白头狼人"] = true,
        ["粘性辐射尘"] = true,
    },
    shadow = {
        ["阿塔莱死亡行者的灵魂"] = true,
        ["费尔库拉"] = true,
        ["鬼灵骑兵"] = true,
        ["鬼灵死亡骑士"] = true,
        ["鬼灵学徒"] = true,
        ["鬼灵战马"] = true,
        ["瘟疫软泥怪"] = true,
        ["伊利法尔"] = true,
    },
    arcane = {
        ["阿塔莱死亡行者的灵魂"] = true,
        ["埃苏罗斯"] = true,
        ["艾索雷葛斯"] = true,
        ["奥术畸兽"] = true,
        ["法力残渣"] = true,
        ["法力恶魔"] = true,
        ["法力脉冲"] = true,
        ["法力怒灵"] = true,
        ["法术之喉"] = true,
        ["费尔库拉"] = true,
        ["鬼灵骑兵"] = true,
        ["鬼灵死亡骑士"] = true,
        ["鬼灵学徒"] = true,
        ["鬼灵战马"] = true,
        ["畸形残渣"] = true,
        ["裂隙怒灵"] = true,
        ["魔法利爪"] = true,
        ["斯克利尔"] = true,
        ["伊利法尔"] = true,
    },
}

-- 静态名单按怪物名称表达“这一类怪物”的固有免疫；战斗中捕获到的结果只属于
-- 当前遇到的具体对象，因此必须按 SuperWoW GUID 保存，避免污染同名怪物。
-- 动态结果只在本次游戏会话中有效，不写入 SavedVariables。
local dynamicDamageSchoolImmuneByGuid = {}

-- 动态免疫学习只在流程卡片开启的短时间窗口内生效。事件仍保持注册，
-- 通过时间戳门禁避免反复注册/注销事件，也不会影响静态名单和已学习结果的查询。
local damageSchoolImmuneCaptureUntil = 0

-- 开启或续期动态伤害系免疫捕获窗口。较短的新窗口不会缩短已有窗口。
function Cat2.ActivateDamageSchoolImmuneCapture(duration)
    duration = tonumber(duration) or 3
    if duration <= 0 then
        return false
    end

    local captureUntil = GetTime() + duration
    if captureUntil > damageSchoolImmuneCaptureUntil then
        damageSchoolImmuneCaptureUntil = captureUntil
    end
    return true
end

function Cat2.IsDamageSchoolImmuneCaptureActive()
    return damageSchoolImmuneCaptureUntil > GetTime()
end

function Cat2.GetDamageSchoolImmuneCaptureRemaining()
    local remaining = damageSchoolImmuneCaptureUntil - GetTime()
    if remaining <= 0 then
        return 0
    end
    return remaining
end

-- 同时接受英文、中文和游戏伤害系掩码，方便不同卡片按自身已有数据调用。
local damageSchoolAliases = {
    ["physical"] = "physical",
    ["物理"] = "physical",
    [1] = "physical",
    ["nature"] = "nature",
    ["自然"] = "nature",
    [8] = "nature",
    ["fire"] = "fire",
    ["火焰"] = "fire",
    [4] = "fire",
    ["frost"] = "frost",
    ["冰霜"] = "frost",
    [16] = "frost",
    ["shadow"] = "shadow",
    ["暗影"] = "shadow",
    [32] = "shadow",
    ["arcane"] = "arcane",
    ["奥术"] = "arcane",
    [64] = "arcane",
    ["holy"] = "holy",
    ["神圣"] = "holy",
    [2] = "holy",
}

-- 能用“免疫”结果确认目标免疫整个伤害系的技能。
--
-- 这里按技能名称登记，因此不同等级无需重复填写。若某个技能的“免疫”只代表
-- 控制、毒药或其他特殊机制免疫，请不要放入本表，避免把它误判成元素免疫。
-- 后续补充技能时只需使用下面的格式：
--     ["技能名称"] = "nature", -- physical/holy/fire/nature/frost/shadow/arcane
local damageSchoolImmuneSpellRules = {
    -- 德鲁伊
    ["愤怒"] = "nature",
    ["虫群"] = "nature",
    ["飓风"] = "nature",
    ["星火术"] = "arcane",
    ["月火术"] = "arcane",

    -- 猎人
    ["奥术射击"] = "arcane",
    ["乱射"] = "arcane",
    ["爆炸陷阱"] = "fire",
    ["献祭陷阱"] = "fire",

    -- 法师
    ["奥术飞弹"] = "arcane",
    ["奥术溃裂"] = "arcane",
    ["奥术涌动"] = "arcane",
    ["魔爆术"] = "arcane",
    ["火球术"] = "fire",
    ["火焰冲击"] = "fire",
    ["冲击波"] = "fire",
    ["炎爆术"] = "fire",
    ["灼烧"] = "fire",
    ["烈焰风暴"] = "fire",
    ["寒冰箭"] = "frost",
    ["冰柱"] = "frost",
    ["冰锥术"] = "frost",
    ["暴风雪"] = "frost",

    -- 圣骑士
    ["驱邪术"] = "holy",
    ["神圣愤怒"] = "holy",
    ["愤怒之锤"] = "holy",
    ["奉献"] = "holy",
    ["神圣震击"] = "holy",
    ["神圣打击"] = "holy",

    -- 牧师
    ["惩击"] = "holy",
    ["神圣之火"] = "holy",
    ["神圣新星"] = "holy",
    ["暗言术：痛"] = "shadow",
    ["精神鞭笞"] = "shadow",
    ["心灵震爆"] = "shadow",
    ["痛苦尖刺"] = "shadow",

    -- 萨满
    ["闪电箭"] = "nature",
    ["闪电链"] = "nature",
    ["大地震击"] = "nature",
    ["地震术"] = "nature",
    ["闪电打击"] = "nature",
    ["烈焰震击"] = "fire",
    ["熔岩爆裂"] = "fire",
    ["冰霜震击"] = "frost",

    -- 术士
    ["暗影箭"] = "shadow",
    ["暗影收割"] = "shadow",
    ["暗影灼烧"] = "shadow",
    ["腐蚀术"] = "shadow",
    ["痛苦诅咒"] = "shadow",
    ["生命虹吸"] = "shadow",
    ["吸取生命"] = "shadow",
    ["吸取灵魂"] = "shadow",
    ["献祭"] = "fire",
    ["灼热之痛"] = "fire",
    ["灵魂之火"] = "fire",
    ["地狱烈焰"] = "fire",
    ["火焰之雨"] = "fire",
    ["燃烧"] = "fire",
}

-- 暴露同一张表，方便其他模块或后续自定义技能直接补充规则。
Cat2.DamageSchoolImmuneSpellRules = damageSchoolImmuneSpellRules

local damageSchoolDisplayNames = {
    physical = "物理",
    holy = "神圣",
    nature = "自然",
    fire = "火焰",
    frost = "冰霜",
    shadow = "暗影",
    arcane = "奥术",
}

local damageSchoolColors = {
    physical = "|cffffffff",
    holy = "|cffffff80",
    nature = "|cff4dff4d",
    fire = "|cffff5a36",
    frost = "|cff80ccff",
    shadow = "|cffb266ff",
    arcane = "|cffcc99ff",
}

local function NormalizeDamageSchool(school)
    if type(school) == "string" then
        school = string.lower(school)
    end
    return damageSchoolAliases[school]
end

-- 登记或移除一条技能规则。school 传 nil/false 时移除该技能。
function Cat2.RegisterDamageSchoolImmuneSpell(spellName, school)
    if type(spellName) ~= "string" or spellName == "" then
        return false
    end

    if school == nil or school == false then
        damageSchoolImmuneSpellRules[spellName] = nil
        return true
    end

    local schoolKey = NormalizeDamageSchool(school)
    if not schoolKey then
        return false
    end

    damageSchoolImmuneSpellRules[spellName] = schoolKey
    return true
end

-- 把本次游戏过程中确认的免疫直接写入现有名单；不会保存到 SavedVariables。
function Cat2.MarkDamageSchoolImmune(targetName, school)
    local schoolKey = NormalizeDamageSchool(school)
    local immuneList = schoolKey and damageSchoolImmuneLists[schoolKey]
    if not immuneList or type(targetName) ~= "string" or targetName == "" then
        return false
    end

    local isNew = immuneList[targetName] ~= true
    immuneList[targetName] = true
    return isNew
end

local function MarkDynamicDamageSchoolImmune(targetGuid, school)
    local schoolKey = NormalizeDamageSchool(school)
    if type(targetGuid) ~= "string" or targetGuid == "" or not schoolKey then
        return false
    end

    local immuneSchools = dynamicDamageSchoolImmuneByGuid[targetGuid]
    if type(immuneSchools) ~= "table" then
        immuneSchools = {}
        dynamicDamageSchoolImmuneByGuid[targetGuid] = immuneSchools
    end

    local isNew = immuneSchools[schoolKey] ~= true
    immuneSchools[schoolKey] = true
    return isNew
end


local function TrimCombatLogName(name)
    if type(name) ~= "string" then
        return nil
    end

    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")
    name = string.gsub(name, "[。%.！!]+$", "")
    if name == "" then
        return nil
    end
    return name
end


local function ExtractImmuneTargetName(message)
    -- 旧版 Cat 和当前中文客户端已经使用过的主要日志格式：
    -- “你的技能施放失败。目标对此免疫。”
    local _, _, targetName = string.find(message, "施放失败。(.-)对此免疫")

    -- 兼容“目标免疫了你的技能”一类格式。
    if not targetName then
        _, _, targetName = string.find(message, "^%s*(.-)免疫了")
    end

    -- 兼容“你的技能对目标造成……免疫”一类扩展日志。
    if not targetName then
        _, _, targetName = string.find(message, "对(.-)造成.-免疫")
    end

    return TrimCombatLogName(targetName)
end


local function FindImmuneSpellRule(message)
    local matchedSpellName = nil
    local matchedSchool = nil
    local matchedLength = 0

    -- 只有日志已经包含“免疫”时才会进入这里。选择最长命中的名称，避免短名称
    -- 与扩展技能同名开头时产生歧义。
    for spellName, school in pairs(damageSchoolImmuneSpellRules) do
        if string.find(message, spellName, 1, true) then
            local nameLength = string.len(spellName)
            if nameLength > matchedLength then
                matchedSpellName = spellName
                matchedSchool = school
                matchedLength = nameLength
            end
        end
    end

    return matchedSpellName, matchedSchool
end


-- 使用 SuperWoW 增强后的原始战斗日志学习免疫。动态结果必须绑定到日志中的 GUID；
-- GUID 当前不可访问时无法可靠排除放逐状态，因此宁可漏记也不按名称猜测。
function Cat2.LearnDamageSchoolImmuneFromMessage(message, targetGuid)
    if type(message) ~= "string" then
        return false
    end

    if not string.find(message, "免疫", 1, true) and
       not string.find(message, "IMMUNE", 1, true) then
        return false
    end

    local spellName, school = FindImmuneSpellRule(message)
    local schoolKey = NormalizeDamageSchool(school)
    if not spellName or not schoolKey then
        return false
    end

    targetGuid = targetGuid or Cat2.MatchGUID(message)
    if type(targetGuid) ~= "string" or targetGuid == "" then
        return false
    end

    -- SuperWoW 允许用 GUID 作为 unit 查询；对象已经离开可访问范围时不做低可信学习。
    if not UnitExists(targetGuid) then
        return false
    end

    -- 放逐产生的是临时全免疫，不能据此推断目标固有免疫某个伤害系。
    if Cat2.Buff and Cat2.Buff("放逐术", targetGuid) then
        return false
    end

    local targetName = UnitName(targetGuid) or ExtractImmuneTargetName(message)
    if not targetName then
        return false
    end

    local isNew = MarkDynamicDamageSchoolImmune(targetGuid, schoolKey)
    if isNew and DEFAULT_CHAT_FRAME then
        local schoolColor = damageSchoolColors[schoolKey] or "|cffffffff"
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cff66ccffCat2：|r发现 |cffffd166[" .. targetName .. "]|r 免疫" ..
            schoolColor .. (damageSchoolDisplayNames[schoolKey] or schoolKey) ..
            "|r伤害，已加入本次免疫名单。"
        )
    end

    return true, targetName, schoolKey, spellName, targetGuid
end


-- 所有职业共用 SuperWoW 的增强战斗日志。RAW_COMBATLOG 的 arg1 是原始事件名，
-- arg2 是带 GUID 的增强消息；不再同时监听原生事件，避免同一条日志被处理两次。
local damageSchoolImmuneEventFrame = CreateFrame("Frame")
if SUPERWOW_STRING then
    Cat2.RegisterOptionalEvent(damageSchoolImmuneEventFrame, "RAW_COMBATLOG")
    damageSchoolImmuneEventFrame:SetScript("OnEvent", function()
        if Cat2.IsDamageSchoolImmuneCaptureActive() and
           (arg1 == "CHAT_MSG_SPELL_SELF_DAMAGE" or
            arg1 == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE") then
            local targetGuid = Cat2.MatchGUID(arg2)
            Cat2.LearnDamageSchoolImmuneFromMessage(arg2, targetGuid)
        end
    end)
end

-- 判断目标是否免疫指定伤害系。目标或伤害系无效时返回 false，不把未知状态误判为免疫。
function Cat2.IsDamageSchoolImmune(unit, school)
    unit = unit or "target"
    local schoolKey = NormalizeDamageSchool(school)
    local immuneList = schoolKey and damageSchoolImmuneLists[schoolKey]
    local name = UnitName(unit)
    if not immuneList or not name then
        return false
    end
    if immuneList[name] == true then
        return true
    end

    local _, guid = UnitExists(unit)
    local dynamicImmuneSchools = guid and dynamicDamageSchoolImmuneByGuid[guid]
    return dynamicImmuneSchools and dynamicImmuneSchools[schoolKey] == true or false
end

-- 与上方相反的便捷接口，适合卡片在施法前直接判断。
-- 目标或伤害系无效时返回 false，避免在信息不足时继续尝试施法。
function Cat2.CanDealSchoolDamage(unit, school)
    unit = unit or "target"
    local schoolKey = NormalizeDamageSchool(school)
    local immuneList = schoolKey and damageSchoolImmuneLists[schoolKey]
    local name = UnitName(unit)
    if not immuneList or not name then
        return false
    end
    if immuneList[name] == true then
        return false
    end

    local _, guid = UnitExists(unit)
    local dynamicImmuneSchools = guid and dynamicDamageSchoolImmuneByGuid[guid]
    return not dynamicImmuneSchools or dynamicImmuneSchools[schoolKey] ~= true
end

function Cat2.IsNatureImmune(unit)
    return Cat2.IsDamageSchoolImmune(unit, "nature")
end

function Cat2.IsPhysicalImmune(unit)
    return Cat2.IsDamageSchoolImmune(unit, "physical")
end

function Cat2.IsFireImmune(unit)
    return Cat2.IsDamageSchoolImmune(unit, "fire")
end

function Cat2.IsFrostImmune(unit)
    return Cat2.IsDamageSchoolImmune(unit, "frost")
end

function Cat2.IsShadowImmune(unit)
    return Cat2.IsDamageSchoolImmune(unit, "shadow")
end

function Cat2.IsArcaneImmune(unit)
    return Cat2.IsDamageSchoolImmune(unit, "arcane")
end

function Cat2.IsHolyImmune(unit)
    return Cat2.IsDamageSchoolImmune(unit, "holy")
end

function Cat2.CanDealNatureDamage(unit)
    return Cat2.CanDealSchoolDamage(unit, "nature")
end

function Cat2.CanDealPhysicalDamage(unit)
    return Cat2.CanDealSchoolDamage(unit, "physical")
end

function Cat2.CanDealFireDamage(unit)
    return Cat2.CanDealSchoolDamage(unit, "fire")
end

function Cat2.CanDealFrostDamage(unit)
    return Cat2.CanDealSchoolDamage(unit, "frost")
end

function Cat2.CanDealShadowDamage(unit)
    return Cat2.CanDealSchoolDamage(unit, "shadow")
end

function Cat2.CanDealArcaneDamage(unit)
    return Cat2.CanDealSchoolDamage(unit, "arcane")
end

function Cat2.CanDealHolyDamage(unit)
    return Cat2.CanDealSchoolDamage(unit, "holy")
end

