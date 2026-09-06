-- 闪避 技能卡片。
local card = {
    id = "rogue_evasion",
    name = "闪避",
    description = "被目标盯着，且生命低于|cff6bc7e0{triggerPercent}%|r时施放闪避",
    details = "被目标盯着，且生命低于卡片设定值时施放闪避。需要存在有效目标。仅在技能可用时尝试执行。",
    sort = 70,
    category = "class",
    classes = {
        ROGUE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_ShadowWard",
    },
    cooldown = {
        type = "spell",
        name = "闪避",
    },
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

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 30

    if not player.targetExists then
        return false
    end

    -- 目标的目标 缺失
    if not UnitExists("targettarget") then
        return false
    end

    local totName = UnitName("targettarget")
	if totName and totName==Cat2.PlayerInformation.basic.name then

        if player.percentHealth <= triggerPercent and Cat2.SpellReady("闪避") then
            Cat2.Cast("闪避")
        end

    end

    return false
end

Cat2.RegisterCard(card)
