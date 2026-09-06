-- 通用流程终止卡：调试时用于阻止当前流程继续执行后续卡片。
local card = {
    id = "common_flow_terminate",
    name = "流程终止",
    description = "立即终止本轮流程，阻止后续卡片执行",
    details = "执行后直接返回成功并终止本轮流程，后续卡片不会继续执行。主要用于流程调试和定位问题。",
    sort = 59.5,
    category = "common",
    icons = {
        "Interface\\Icons\\INV_Misc_ScrewDriver_01",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    return true
end

Cat2.RegisterCard(card)
