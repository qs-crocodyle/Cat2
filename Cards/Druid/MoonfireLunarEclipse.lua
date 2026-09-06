-- 月火术（月蚀）：仅在玩家拥有月蚀 Buff 时执行原月火术逻辑。
local card = {
    id = "druid_moonfire_lunar_eclipse",
    name = "月火术（月蚀）",
    description = "月蚀生效时施放奥术持续伤害",
    details = "仅在月蚀生效时执行月火术的原有逻辑。需要存在有效目标；目标奥术免疫或已有月火术效果时不会施放。成功执行时会阻断本轮后续卡片。",
    -- 紧随原“月火术”卡片。
    sort = 111,
    category = "class",
    canStopSequence = true,
    classes = {
        DRUID = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_StarFall",
        "Interface\\Icons\\Spell_Nature_WispSplode",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if not player.buff["月蚀"] then
        return false
    end

    if Cat2.IsArcaneImmune() then
        return false
    end

    if not Cat2.GetMoonfireDot() then
        Cat2.Cast("月火术")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
