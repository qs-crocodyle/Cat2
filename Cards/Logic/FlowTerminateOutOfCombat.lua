-- 玩家未处于战斗中时，终止本轮后续流程。
local card = {
    id = "common_flow_terminate_out_of_combat",
    name = "非战斗中 流程终止",
    description = "玩家未处于战斗中时，终止本轮后续流程",
    details = "按本轮玩家战斗状态判断：非战斗中终止后续卡片执行，战斗中继续执行。不依赖目标是否存在或目标的战斗状态。",
    sort = 59.7,
    category = "logic",
    behavior = "logic",
    canStopSequence = true,
    icons = {
        "Interface\\Icons\\INV_Misc_ScrewDriver_01",
        "Interface\\Icons\\Ability_DualWield",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    return context.playerInformation.temporary.inCombat == false
end

Cat2.RegisterCard(card)
