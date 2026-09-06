-- 冲击波 技能卡片。
local card = {
    id = "mage_blast_wave",
    name = "冲击波",
    description = "周围|cff6bc7e0{scanRange}码|r内有敌人时，施放冲击波",
    details = "已学会冲击波且周围设定距离内至少有1个敌人时施放，默认扫描10码。敌人扫描需要SuperWoW和UnitXP。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 30,
    category = "class",
    classes = {
        MAGE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_Excorcism_02",
    },
    cooldown = {
        type = "spell",
        name = "冲击波",
    },
    optionSchema = {
        {
            key = "scanRange",
            type = "number",
            label = "扫描距离",
            shortLabel = "距",
            unit = "码",
            default = 10,
            minimum = 1,
            maximum = 50,
        },
    },
}

local spellExists = false

function card.RefreshRuntimeData()
    spellExists = Cat2.GetSpellID("冲击波") ~= 0
end

function card.Execute(context, step)
    -- 冲击波是天赋技能；未学习时不继续扫描周围敌人。
    if not spellExists then
        return false
    end

    local scanRange = context:GetStepOption(step, "scanRange") or 10
    local nearby = Cat2.ScanNearbyEnemies(scanRange)
    if nearby < 1 then
        return false
    end

    if Cat2.SpellReadyOffset("冲击波") then
        Cat2.Cast("冲击波")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
