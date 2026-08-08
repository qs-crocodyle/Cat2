-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_cat_form",
    -- 界面中显示的卡片标题。
    name = "猎豹形态",
    -- 卡片标题下方显示的简短说明。
    description = "切换并保持猎豹形态",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "切换并保持猎豹形态。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 20,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        DRUID = 2,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\Ability_Druid_CatForm",
    },
}

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end

-- 返回后续流程执行器读取的动作描述。
function card.Execute(context)
    
    if not Cat2.PlayerInformation.temporary.buff["猎豹形态"] then
        CastSpellByName("猎豹形态")
    end

end

Cat2.RegisterCard(card)
