-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "common_auto_pick",
    -- 界面中显示的卡片标题。
    name = "自动交互",
    -- 卡片标题下方显示的简短说明。
    description = "自动拾取，如：怪物尸体、机器人等，需Interact模组",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "自动拾取，如：怪物尸体、机器人等，需Interact模组。会检查目标距离。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 50,
    -- 仅能是 common、item、class 三种分类之一。
    category = "common",
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\inv_pet_broom",
    },
}

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end

local DelayPickTimer = 0

-- 返回后续流程执行器读取的动作描述。
function card.Execute(context)

    if GetTime()-DelayPickTimer<0 then
        return
    end

    if UnitExists("target") then

        if UnitIsDeadOrGhost("target") then
            ClearTarget()
            return
        end

        if Cat2.TargetDistance() then
            return
        end
    end

    pcall(function()
        if InteractNearest then
            InteractNearest(1)
        else
            UnitXP("interact", 1)
        end
    end)

    DelayPickTimer = GetTime() + 0.5

end

Cat2.RegisterCard(card)
