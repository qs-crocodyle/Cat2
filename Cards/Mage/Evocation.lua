-- 唤醒 技能卡片。
local card = {
    id = "mage_evocation",
    name = "唤醒",
    description = "蓝量<|cff6bc7e0{triggerPercent}%|r时，施放唤醒",
    details = "蓝量低于卡片设定值时，施放唤醒。会检查战斗状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 100,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_Purge",
    },
    cooldown = {
        type = "spell",
        name = "唤醒",
    },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发蓝量",
            shortLabel = "蓝",
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

    -- 未进入战斗
    if not player.inCombat then
        return false
    end

    if Cat2.SpellReady("唤醒") and player.percentMana < triggerPercent then
        Cat2.Cast("唤醒")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
