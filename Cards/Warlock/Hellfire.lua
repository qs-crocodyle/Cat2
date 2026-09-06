-- 地狱烈焰技能卡片：身边敌人数量超过阈值时开始引导。
local card = {
    id = "warlock_hellfire",
    name = "地狱烈焰",
    description = "周围10码内敌人>|cff6bc7e0{enemyThreshold}|r时，施放地狱烈焰",
    details = "周围10码内敌人数量超过卡片设定值时施放地狱烈焰，默认要求敌人数大于2。敌人扫描需要SuperWoW和UnitXP。仅在已学会且技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 40.075,
    category = "class",
    classes = {
        WARLOCK = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Incinerate",
    },
    cooldown = {
        type = "spell",
        name = "地狱烈焰",
    },
    optionSchema = {
        {
            key = "enemyThreshold",
            type = "number",
            label = "敌人数阈值",
            shortLabel = "敌",
            unit = "个",
            default = 2,
            minimum = 0,
            maximum = 39,
        },
    },
}

local spellExists = false

function card.RefreshRuntimeData()
    spellExists = Cat2.GetSpellID("地狱烈焰") ~= 0
end

function card.Execute(context, step)
    if not spellExists then
        return false
    end

    local enemyThreshold = context:GetStepOption(step, "enemyThreshold") or 2
    local nearby = Cat2.ScanNearbyEnemies(10)
    if nearby <= enemyThreshold then
        return false
    end

    if Cat2.SpellReady("地狱烈焰") then
        Cat2.Cast("地狱烈焰")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
