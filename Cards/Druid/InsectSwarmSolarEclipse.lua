-- 虫群（日蚀）：仅在玩家拥有日蚀 Buff 时执行原虫群逻辑。
local card = {
    id = "druid_insect_swarm_solar_eclipse",
    name = "虫群（日蚀）",
    description = "日蚀生效时施放自然持续伤害",
    details = "仅在日蚀生效时执行虫群的原有逻辑。需要存在有效目标；目标自然免疫或已有虫群效果时不会施放。成功执行时会阻断本轮后续卡片。",
    -- 紧随原“虫群”卡片。
    sort = 113,
    category = "class",
    canStopSequence = true,
    classes = {
        DRUID = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_InsectSwarm",
        "Interface\\Icons\\Spell_Nature_AbolishMagic",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if not player.buff["日蚀"] then
        return false
    end

    if Cat2.IsNatureImmune() then
        return false
    end

    if not Cat2.GetInsectSwarmDot() then
        Cat2.Cast("虫群")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
