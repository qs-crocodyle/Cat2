-- 魔爆术 技能卡片。
local card = {
    id = "mage_arcane_explosion",
    name = "魔爆术",
    description = "周围8码内敌人>|cff6bc7e0{enemyThreshold}|r时，施放魔爆术",
    details = "周围8码内敌人数量超过卡片设定值时施放魔爆术，默认要求敌人数大于3。敌人扫描需要SuperWoW和UnitXP。成功执行时会阻断本轮后续卡片。",
    sort = 40,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_WispSplode",
    },
    optionSchema = {
        {
            key = "enemyThreshold",
            type = "number",
            label = "敌人数阈值",
            shortLabel = "敌",
            unit = "个",
            default = 3,
            minimum = 0,
            maximum = 39,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local enemyThreshold = context:GetStepOption(step, "enemyThreshold") or 3
    local nearby = Cat2.ScanNearbyEnemies(8)

    if nearby > enemyThreshold then
        Cat2.Cast("魔爆术")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
