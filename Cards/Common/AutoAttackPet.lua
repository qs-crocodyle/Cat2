-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "common_auto_attack_pet",
    -- 界面中显示的卡片标题。
    name = "宠物自动攻击",
    -- 卡片标题下方显示的简短说明。
    description = "让宠物开始或维持普通攻击",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "让宠物开始或维持普通攻击。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 11,
    -- 仅能是 common、item、class 三种分类之一。
    category = "common",
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\Ability_Rogue_ShadowStrikes",
    },
}

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end


-- 返回后续流程执行器读取的动作描述。
function card.Execute(context)

    PetAttack()

end

Cat2.RegisterCard(card)
