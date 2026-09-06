-- 嗜血 技能卡片。
local card = {
    id = "warrior_bloodthirst",
    name = "嗜血",
    description = "怒气达到|cff6bc7e0{rageThreshold}|r且冷却好时，施放嗜血",
    details = "怒气达到卡片设定值且冷却好时，施放嗜血。未单独设置时使用默认值30。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 130,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_BloodLust",
    },
    cooldown = {
        type = "spell",
        name = "嗜血",
    },
    optionSchema = {
        {
            key = "rageThreshold",
            type = "number",
            label = "怒气阈值",
            shortLabel = "怒",
            default = 30,
            minimum = 30,
            maximum = 100,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local rageThreshold = context:GetStepOption(step, "rageThreshold") or 30

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    if player.power>=rageThreshold and Cat2.SpellReady("嗜血") then
        Cat2.Cast("嗜血")
        return true
    end

end

Cat2.RegisterCard(card)
