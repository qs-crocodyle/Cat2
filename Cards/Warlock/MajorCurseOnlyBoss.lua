-- 大诅咒仅对强敌生效的被动卡片。
local card = {
    id = "warlock_major_curse_only_boss",
    name = "大诅咒 忽略非强敌时",
    description = "大诅咒仅对强敌目标生效",
    details = "大诅咒仅对强敌目标生效。作为被动规则，启用时影响当前流程。",
    sort = 75,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = { WARLOCK = 1 },
    icons = { "Interface\\Icons\\INV_Misc_Head_Dragon_01" },
}

function card.RefreshRuntimeData()
end

-- 被动卡片先于普通卡片应用，共享参数不受自身排列位置影响。
function card.Apply(context)
    context.parameters.warlockMajorCurseOnlyBoss = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
