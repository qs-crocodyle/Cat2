-- 斩杀阶段允许中断当前读条的被动规则。
local card = {
    id = "warrior_interrupt_cast_for_execute",
    name = "斩杀时中断读条",
    description = "进入斩杀阶段时，允许流程中断当前读条",
    details = "进入斩杀阶段时，允许流程中断当前读条。作为被动规则，启用时影响当前流程。",
    sort = 99,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\INV_Sword_48",
    },
}

function card.RefreshRuntimeData()
end

function card.Apply(context)
    context.parameters.warriorInterruptCastForExecute = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
