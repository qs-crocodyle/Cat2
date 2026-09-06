-- 奥术强化 技能卡片。
local card = {
    id = "mage_arcane_power",
    name = "奥术强化",
    description = "蓝量>|cff6bc7e0{minimumMana}%|r时，冷却后施放奥术强化",
    details = "蓝量高于卡片设定值时，冷却后施放奥术强化。会检查战斗状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 120,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_Lightning",
    },
    cooldown = {
        type = "spell",
        name = "奥术强化",
    },
    optionSchema = {
        {
            key = "minimumMana",
            type = "number",
            label = "最低蓝量",
            shortLabel = "蓝",
            unit = "%",
            default = 50,
            minimum = 22,
            maximum = 99,
        },
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,19)
end

function card.Execute(context, step)

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    local player = Cat2.PlayerInformation.temporary
    local minimumMana = context:GetStepOption(step, "minimumMana") or 50

    -- 未进入战斗
    if not player.inCombat then
        return false
    end

    if Cat2.SpellReadyOffset("奥术强化",1.5) and player.percentMana > minimumMana then
        Cat2.Cast("奥术强化")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
