-- 爆发类药水仅近战距离的被动卡片。
-- 启用后，仅影响明确读取 burstOnlyMelee 参数的消耗品卡。
local card = {
    id = "item_burst_only_melee",
    name = "爆发类药水 仅近战距离",
    description = "爆发类药水仅在接近敌人时启用",
    details = "爆发类药水仅在近战距离内启用。作为被动规则，启用时影响当前流程中的菊花茶、魂能之速、强效怒气药水与加速药水。",
    sort = 141,
    behavior = "passive",
    unique = true,
    category = "item",
    icons = {
        "Interface\\Icons\\Ability_Warrior_InnerRage",
    },
}

function card.RefreshRuntimeData()
end

-- 被动卡先于普通卡应用，共享参数不受自身排列位置影响。
function card.Apply(context)
    context.parameters.burstOnlyMelee = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
