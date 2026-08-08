-- 死亡标记 技能卡片。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "rogue_marked_for_death",
    -- 界面中显示的卡片标题。
    name = "死亡标记",
    -- 卡片标题下方显示的简短说明。
    description = "技能冷却后，施放死亡标记",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "技能冷却后，施放死亡标记。需要存在有效目标。会检查目标距离。会检查当前资源。仅在技能可用时尝试执行。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 130,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        ROGUE = 3,
    },
    -- 默认使用问号图标；登录后会优先从技能书读取同名技能的真实图标。
    icons = {
        "Interface\\Icons\\Ability_Creature_Cursed_02",
    },
}

local allowUse = 0

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(3,20)
end

-- 预留卡片功能入口；后续可在此加入死亡标记的施放条件与动作。
function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    if player.power>=40 and Cat2.SpellReady("死亡标记") and not player.buff["利用弱点"] and Cat2.TargetDistance() then
        CastSpellByName("死亡标记")
    end

    return false
end

Cat2.RegisterCard(card)
