-- 奥术强化低蓝保险卡；应放在流程前部，以便及时阻断后续耗蓝动作。
local card = {
    id = "mage_arcane_power_fuse",
    name = "奥术强化 保险丝",
    description = "奥术强化期间蓝量<25%时阻断流程，请放在流程前面",
    details = "奥术强化 Buff 存在且蓝量低于25%时，立即阻断本轮后续卡片。请将此卡放在流程前部，否则排在它前面的卡片仍会执行。",
    sort = 122,
    category = "class",
    canStopSequence = true,
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_WispHeal",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if player.buff["奥术强化"] and player.percentMana<25.0 then
        return true
    end

    return false
end

Cat2.RegisterCard(card)
