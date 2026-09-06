-- 动态元素免疫捕获开关；作为被动卡片，不受流程排列位置影响。
local card = {
    id = "common_capture_elemental_immunity",
    name = "捕获元素免疫",
    description = "流程执行时，允许捕获元素伤害免疫",
    details = "启用后，每次执行当前流程都会开启或续期3秒元素免疫捕获窗口；停止执行流程3秒后不再学习新的免疫。已经捕获的结果仍在本次游戏会话中生效，静态免疫名单不受影响。需要SuperWoW。",
    sort = 55.1,
    behavior = "passive",
    unique = true,
    category = "common",
    icons = {
        "Interface\\Icons\\Spell_Holy_MagicalSentry",
    },
}

function card.RefreshRuntimeData()
end

function card.Apply(context)
    Cat2.ActivateDamageSchoolImmuneCapture(3)
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
