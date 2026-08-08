-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_enrage",
    -- 界面中显示的卡片标题。
    name = "狂怒",
    -- 卡片标题下方显示的简短说明。
    description = "获得怒气，血之狂暴存在时不会开启",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "获得怒气，血之狂暴存在时不会开启。需要存在有效目标。会检查目标距离。会检查战斗状态。仅在技能可用时尝试执行。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 330,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        DRUID = 2,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\Ability_Druid_Enrage",
    },
}

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end

-- 返回后续流程执行器读取的动作描述。
function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end

	-- 判定距离
    if not Cat2.TargetDistance() then
        return
    end


    if not player.buff["血之狂暴"] and Cat2.SpellReady("狂怒") and player.inCombat then
        CastSpellByName("狂怒")
    end

    return false
end

Cat2.RegisterCard(card)
