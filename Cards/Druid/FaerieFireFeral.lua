-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_faerie_fire_feral",
    -- 界面中显示的卡片标题。
    name = "精灵之火（野性）",
    -- 卡片标题下方显示的简短说明。
    description = "降低目标护甲",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "降低目标护甲。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 140,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    canStopSequence = true,
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        DRUID = 2,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\Spell_Nature_FaerieFire",
    },
}

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end

-- 仅在熊形态、巨熊形态或猎豹形态下施放野性版本的精灵之火。
function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    if not player.buff["熊形态"] and not player.buff["巨熊形态"] and not player.buff["猎豹形态"] then
        return false
    end

    if Cat2.SpellReady("精灵之火（野性）") then
        if not player.targetBuff["精灵之火"] and not player.targetBuff["精灵之火（野性）"] then
            CastSpellByName("精灵之火（野性）")
            return true
        end
    end

    return false
end

Cat2.RegisterCard(card)
