-- 爆发类功能仅对强敌启用的被动卡片。
local card = {
    id = "item_burst_only_boss",
    name = "爆发类药水 仅强敌时",
    description = "爆发类药水仅在强敌阶段启用",
    details = "爆发类药水仅在强敌阶段启用。作为被动规则，启用时影响当前流程。",
    sort = 140,
    behavior = "passive",
    unique = true,
    category = "item",
    icons = {
        "Interface\\Icons\\Spell_Nature_BloodLust",
    },
}

function card.RefreshRuntimeData()
end

-- 被动卡片先于普通卡片应用，共享参数不受自身排列位置影响。
function card.Apply(context)
    context.parameters.burstOnlyBoss = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
