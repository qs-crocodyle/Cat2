-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_barkskin",
    -- 界面中显示的卡片标题。
    name = "树皮术",
    -- 卡片标题下方显示的简短说明。
    description = "血量低于|cff6bc7e0{triggerPercent}%|r时开启树皮术",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "血量低于卡片设定值时，开启树皮术以降低所受伤害。会检查战斗状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 130,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        DRUID = 1,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\Spell_Nature_StoneClawTotem",
    },
    cooldown = { type = "spell", name = "树皮术" },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发生命",
            shortLabel = "血",
            unit = "%",
            default = 30,
            minimum = 1,
            maximum = 99,
        },
    },
}

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end

-- 在树皮术未生效时施放；返回 true 表示本次执行已经施放技能。
function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 30

    -- 在战斗中
    if not player.inCombat then
        return false
    end

    -- 形态保护
    if player.buff["熊形态"] or player.buff["巨熊形态"] or player.buff["猎豹形态"] then
        return false
    end

    if player.percentHealth < triggerPercent and Cat2.SpellReady("树皮术") then
        Cat2.Cast("树皮术")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
