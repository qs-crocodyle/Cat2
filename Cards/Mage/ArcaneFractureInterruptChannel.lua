-- 只允许打断奥术飞弹、补充奥术溃裂的技能卡片。
local card = {
    id = "mage_arcane_fracture_interrupt_channel",
    name = "奥术溃裂（断条补溃裂）",
    description = "没有奥术溃裂增益时，允许打断奥术飞弹并施放奥术溃裂",
    details = "玩家身上没有奥术溃裂增益且技能冷却完成时，仅允许打断当前奥术飞弹引导并施放奥术溃裂。其他引导或无法确认名称的引导不会被中断。没有引导时正常施放。需要存在有效目标；目标奥术免疫时不会施放。成功执行时会阻断本轮后续卡片。",
    sort = 22,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Arcane_Blast",
    },
    cooldown = {
        type = "spell",
        name = "奥术溃裂",
    },
}

local allowUse = 0
local distance = 30

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,9)
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("奥术溃裂", "等级 1"), "(%d+)码距离"))
    if not distance then distance = 30 end
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 目标奥术免疫时，不再尝试施放奥术伤害技能。
    if Cat2.IsArcaneImmune() then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    if allowUse == 0 then
        return false
    end

    if player.buff["奥术溃裂"] then
        return false
    end

    if Cat2.SpellReadyOffset("奥术溃裂", 1.5) then
        return Cat2.CastMageWithArcaneMissilesInterrupt("奥术溃裂") == true
    end

    return false
end

Cat2.RegisterCard(card)
