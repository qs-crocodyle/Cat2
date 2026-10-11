-- 假死时终止流程：玩家身上存在假死 Buff 时阻断后续卡片。
local card = {
    id = "hunter_feign_death_flow_terminate",
    name = "假死时 流程终止",
    description = "玩家处于假死状态时，终止本轮后续流程",
    details = "检查玩家身上的假死 Buff；存在时立即终止本轮流程，不存在时继续执行后续卡片。不会主动施放假死。没有可配置参数。建议放在攻击卡之前，避免攻击动作打断假死。",
    sort = 110.1,
    category = "class",
    behavior = "logic",
    canStopSequence = true,
    classes = {
        HUNTER = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_FeignDeath",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = context.playerInformation.temporary
    return player.buff and player.buff["假死"] and true or false
end

Cat2.RegisterCard(card)
