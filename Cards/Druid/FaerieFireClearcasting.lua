-- 精灵之火（清晰预兆）卡片。
local card = {
    id = "druid_faerie_fire_clearcasting",
    name = "精灵之火（清晰预兆）",
    description = "释放精灵之火，以博清晰预兆的触发",
    details = "释放精灵之火，以博清晰预兆的触发。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 141,
    category = "class",
    classes = {
        DRUID = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_FaerieFire",
        "Interface\\Icons\\Spell_Nature_CrystalBall",
    },
    cooldown = { type = "spell", name = "精灵之火" },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if context.parameters.faerieFireTargetCombatOnly and not player.targetInCombat then
        return false
    end

    -- 非野性版本不在熊形态、巨熊形态或猎豹形态下施放。
    if player.buff["熊形态"] or player.buff["巨熊形态"] or player.buff["猎豹形态"] then
        return false
    end

    Cat2.Cast("精灵之火")
    return true
end

Cat2.RegisterCard(card)
