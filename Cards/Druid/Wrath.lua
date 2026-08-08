-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_wrath",
    -- 界面中显示的卡片标题。
    name = "愤怒",
    -- 卡片标题下方显示的简短说明。
    description = "施放自然伤害法术",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "施放自然伤害法术。需要存在有效目标。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 100,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        DRUID = 1,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\Spell_Nature_AbolishMagic",
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


    Cat2.CastWithoutNampower("愤怒")
end

Cat2.RegisterCard(card)
