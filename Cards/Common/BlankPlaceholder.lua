-- 通用空白占位卡：仅用于调整流程排版，不执行任何操作。
local card = {
    id = "common_blank_placeholder",
    name = "空白占位",
    description = "无实际功能，仅用于流程占位，用于小窗排版",
    details = "无实际功能，仅用于流程占位，用于小窗排版。",
    sort = 60,
    category = "common",
    icons = {
        "Interface\\Icons\\Trade_Engineering",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    return false
end

Cat2.RegisterCard(card)
