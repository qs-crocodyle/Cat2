-- 顺劈斩仅统计正面敌人的被动规则。
local card = {
    id = "warrior_cleave_front_only",
    name = "顺劈斩 仅正面敌人",
    description = "顺劈斩及其分支只统计位于正面的附近敌人",
    details = "启用后，顺劈斩和自动英勇打击/顺劈斩会逐个检查7码内的敌人，只统计位于玩家正面的目标；正面敌人至少2个时才允许施放顺劈斩。需要SuperWoW与UnitXP支持。作为被动规则，启用时影响当前流程。",
    sort = 93,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_Cleave",
    },
}

function card.RefreshRuntimeData()
end

function card.Apply(context)
    -- 普通卡片通过这个参数判断是否需要过滤背面敌人。
    context.parameters.warriorCleaveFrontOnly = true
end

function card.Validate(context)
    return true
end

-- 返回当前流程允许顺劈斩命中的附近敌人数。
-- 未启用本被动时保持原逻辑；启用后逐个排除位于玩家背面的敌人。
function Cat2.GetEligibleCleaveEnemyCount(context, range)
    local nearby, _, nearbyList = Cat2.ScanNearbyEnemies(range)
    if not context.parameters.warriorCleaveFrontOnly then
        return nearby
    end
    if not Cat2.UnitXP or type(nearbyList) ~= "table" then
        return 0
    end

    local frontCount = 0
    for unit in pairs(nearbyList) do
        -- behind为假，表示该敌人位于玩家正面。
        if not UnitXP("behind", unit, "player") then
            frontCount = frontCount + 1
        end
    end
    return frontCount
end

Cat2.RegisterCard(card)
