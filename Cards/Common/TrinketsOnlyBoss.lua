-- 饰品仅对强敌开启的被动卡片。
local card = {
    id = "common_trinkets_only_boss",
    name = "饰品/爆发 仅强敌时",
    description = "饰品和爆发仅在强敌阶段启用",
    details = "饰品和爆发仅在强敌阶段启用。作为被动规则，启用时影响当前流程。",
    sort = 44,
    behavior = "passive",
    unique = true,
    category = "common",
    icons = {
        "Interface\\Icons\\INV_Misc_Head_Dragon_01",
    },
}

function card.RefreshRuntimeData()
end

-- 被动卡片先于普通卡片应用，共享参数不受自身排列位置影响。
function card.Apply(context)
    context.parameters.trinketsOnlyBoss = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
