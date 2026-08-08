-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_reform",
    -- 界面中显示的卡片标题。
    name = "重整",
    -- 卡片标题下方显示的简短说明。
    description = "条件：能量<25, GCD<0.2, 猛虎保护8秒",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "条件：能量<25, GCD<0.2, 猛虎保护8秒。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 400,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    canStopSequence = true,
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        DRUID = 2,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\spell_reshift_2",
    },
}

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end

-- 返回后续流程执行器读取的动作描述。
function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if GetTime()-Cat2.DruidMHTimer>8 then
        if player.power<25 and player.gcd<0.2 and player.mana>=400 then
            Cat2.CastWithoutNampower("重整")
		    return true
        end
    end

end

Cat2.RegisterCard(card)
