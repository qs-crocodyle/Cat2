-- 烈焰风暴三种落点版本共用的等级交替被动。
local card = {
    id = "mage_flamestrike_alternate_ranks",
    name = "烈焰风暴 等级交替",
    description = "烈焰风暴在最高与次高等级之间交替施放",
    details = "影响烈焰风暴（自己）、烈焰风暴（目标）和烈焰风暴（指向），三张卡共用交替状态。首次使用当前已学会的最高等级，确认施放成功后，下次改用次高等级，之后交替施放；失败或取消不会切换等级。距上次成功施放满10秒后，重新从最高等级开始。只学会一个等级时始终使用该等级。需要SuperWoW或Nampower支持施法成功确认。被动效果不受本卡在流程中的排列位置影响；停用后恢复原有施法等级。",
    sort = 55.4,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = { MAGE = 2 },
    icons = { "Interface\\Icons\\Spell_Fire_SelfDestruct" },
}

function card.RefreshRuntimeData()
end

function card.Apply(context)
    context.parameters.mageFlamestrikeAlternateRanks = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
