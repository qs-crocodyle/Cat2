-- 痛苦诅咒 技能卡片。
local card = {
    id = "warlock_curse_of_agony",
    name = "痛苦诅咒",
    description = "保持并施放痛苦诅咒",
    details = "保持并施放痛苦诅咒。需要存在有效目标；目标暗影免疫时不会施放。成功执行时会阻断本轮后续卡片。",
    sort = 80,
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",
    },
}

local distance = 30

function card.RefreshRuntimeData()

    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("痛苦诅咒", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 30
    end

    local CurseAgonyDuration = 24

    CurseAgonyDuration = tonumber(Cat2.Match(Cat2.GetSpellTooltip("痛苦诅咒","等级 5"), "使其在(%d+%.%d+)"))
    if not CurseAgonyDuration then CurseAgonyDuration=24 end

    Cat2.SetCurseAgonyDuration(CurseAgonyDuration)

end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 目标暗影免疫时，不再尝试施放暗影伤害技能。
    if Cat2.IsShadowImmune() then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    local dotOnlyBoss = context and context.parameters and context.parameters.warlockDotOnlyBoss
    if dotOnlyBoss and not Cat2.IsBossTarget() then
        return false
    end

    if not Cat2.GetCurseAgonyDot() then
        Cat2.CastWarlockDot(context, "痛苦诅咒")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
