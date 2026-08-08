-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_demoralizing_roar",
    -- 界面中显示的卡片标题。
    name = "挫志咆哮",
    -- 卡片标题下方显示的简短说明。
    description = "目标没有挫志时触发",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "目标没有挫志时触发。需要存在有效目标。会检查目标距离。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 350,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        DRUID = 2,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\Ability_Druid_DemoralizingRoar",
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
    if not Cat2.TargetDistance("target",7) then
        return
    end


    if player.power>=10 then
        if not player.targetBuff["挫志咆哮"] and not player.targetBuff["挫志怒吼"] then
            CastSpellByName("挫志咆哮")
            return true
        end
    end

    return false
end

Cat2.RegisterCard(card)
