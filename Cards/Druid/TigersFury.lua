-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_tigers_fury",
    -- 界面中显示的卡片标题。
    name = "猛虎之怒",
    -- 卡片标题下方显示的简短说明。
    description = "自动保持猛虎之怒",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "自动保持猛虎之怒。会检查战斗状态。会检查当前资源。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 423,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        DRUID = 2,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\Ability_Mount_JungleTiger",
    },
}

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end

-- 猛虎之怒时间
Cat2.DruidMHTimer = 0

-- 返回后续流程执行器读取的动作描述。
function card.Execute(context)

    if Cat2.PlayerInformation.temporary.inCombat then
	    if (not Cat2.DruidMHTimer or GetTime()-Cat2.DruidMHTimer>17) and Cat2.PlayerInformation.temporary.power>=30 then
		    CastSpellByName("猛虎之怒")
		    Cat2.DruidMHTimer=GetTime()
	    end
    else
	    if (not Cat2.DruidMHTimer or GetTime()-Cat2.DruidMHTimer>8) and Cat2.PlayerInformation.temporary.power>=80 then
		    CastSpellByName("猛虎之怒")
		    Cat2.DruidMHTimer=GetTime()
	    end
    end

end

Cat2.RegisterCard(card)
