-- 自动锁敌忽略未进战斗目标的被动规则。
local card = {
    id = "common_auto_target_ignore_out_of_combat",
    name = "自动锁敌 忽略 未进战斗目标",
    description = "自动锁敌及其分支不会选择尚未进入战斗的目标",
    details = "启用后，自动锁敌（近战）、自动锁敌（远程）、自动锁敌（8码成串）和自动锁敌（最远敌人）只会选择已经进入战斗的敌对目标。作为被动规则，启用时影响当前流程。",
    sort = 24,
    behavior = "passive",
    unique = true,
    category = "common",
    icons = {
        "Interface\\Icons\\Ability_Hunter_SniperShot",
    },
}

function card.RefreshRuntimeData()
end

-- 被动卡片先于普通卡片应用，共享参数不受自身排列位置影响。
function card.Apply(context)
    context.parameters.autoTargetIgnoreOutOfCombat = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
