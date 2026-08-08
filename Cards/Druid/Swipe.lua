-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_swipe",
    -- 界面中显示的卡片标题。
    name = "挥击",
    -- 卡片标题下方显示的简短说明。
    description = "攻击附近多个敌人",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "攻击附近多个敌人。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 320,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        DRUID = 2,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\INV_Misc_MonsterClaw_03",
    },
}

local swipePower = 20

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
    -- 天赋
    swipePower = 20-Cat2.IsTalentLearned(2,1)

	if Cat2.CheckInventoryItemName(18,"蛮兽神像") then swipePower = swipePower-3 end
end

-- 返回后续流程执行器读取的动作描述。
function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end


    if Cat2.SpellReady("野蛮撕咬") then
        if player.power>=swipePower+30 then
            CastSpellByName("挥击")
        end
    else
        if player.power>=swipePower then
            CastSpellByName("挥击")
        end
    end

    return false
end

Cat2.RegisterCard(card)
