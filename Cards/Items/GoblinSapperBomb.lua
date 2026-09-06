-- 地精工兵炸弹卡片；周围聚集大量敌人时自动使用。
local card = {
    id = "item_goblin_sapper_bomb",
    name = "地精工兵炸药",
    description = "周围敌人>=|cff6bc7e0{enemyThreshold}|r且冷却恢复时使用，需SuperWoW",
    details = "身边敌人数量达到或超过卡片设定值，且地精工兵炸弹冷却恢复时使用。默认敌人数阈值为6。敌人扫描需要SuperWoW模组支持。成功使用时会阻断本轮后续卡片。",
    sort = 150,
    category = "item",
    canStopSequence = true,
    icons = {
        "Interface\\Icons\\Spell_Fire_SelfDestruct",
    },
    cooldown = {
        type = "item",
        name = "地精工兵炸药",
    },
    optionSchema = {
        {
            key = "enemyThreshold",
            type = "number",
            label = "敌人数阈值",
            shortLabel = "敌",
            default = 6,
            minimum = 1,
            maximum = 40,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local enemyThreshold = context:GetStepOption(step, "enemyThreshold") or 6
    local nearby = Cat2.ScanNearbyEnemies(8)

    if nearby >= enemyThreshold and Cat2.GetItemByNameCD("地精工兵炸药") then
        if Cat2.UseItemByName("地精工兵炸药") then
            return true
        end
    end

    return false
end

Cat2.RegisterCard(card)
