-- 当前目标处于放逐状态时，暂停执行后续流程。
local card = {
    id = "common_pause_when_target_banished",
    name = "目标放逐时 暂停",
    description = "目标受到放逐术影响时暂停流程",
    details = "目标受到放逐术影响时暂停流程。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 55,
    category = "common",
    icons = {
        "Interface\\Icons\\Spell_Shadow_Cripple",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if player.targetBuff["放逐术"] then
        return true
    end

    return false
end

Cat2.RegisterCard(card)
