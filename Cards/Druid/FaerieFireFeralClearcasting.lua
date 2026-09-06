-- 精灵之火（野性）（清晰预兆）卡片；复用原卡片逻辑。
local card = {
    id = "druid_faerie_fire_feral_clearcasting",
    name = "精灵之火（野性）（清晰预兆）",
    description = "释放精灵之火，以博清晰预兆的触发",
    details = "释放精灵之火，以博清晰预兆的触发。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 141,
    category = "class",
    canStopSequence = true,
    classes = {
        DRUID = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_FaerieFire",
        "Interface\\Icons\\Spell_Nature_CrystalBall",
    },
    cooldown = { type = "spell", name = "精灵之火（野性）" },
}

function card.RefreshRuntimeData()
end

-- 仅在熊形态、巨熊形态或猎豹形态下施放野性版本的精灵之火。
function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if context.parameters.faerieFireFeralTargetCombatOnly and not player.targetInCombat then
        return false
    end

    if context.parameters.faerieFireFeralMeleeOnly and not Cat2.TargetDistance() then
        return false
    end

    if not player.buff["熊形态"] and not player.buff["巨熊形态"] and not player.buff["猎豹形态"] then
        return false
    end

    if Cat2.SpellReady("精灵之火（野性）") then
        Cat2.Cast("精灵之火（野性）")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
