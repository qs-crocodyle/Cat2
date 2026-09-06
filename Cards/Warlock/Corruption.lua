-- 腐蚀术 技能卡片。
local card = {
    id = "warlock_corruption",
    name = "腐蚀术",
    description = "对目标保持并施放腐蚀术",
    details = "对目标保持并施放腐蚀术。需要存在有效目标；目标暗影免疫时不会施放。成功执行时会阻断本轮后续卡片。",
    sort = 90,
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_AbominationExplosion",
    },
}

local CorruptionTalent = 0
local distance = 30

function card.RefreshRuntimeData()

    CorruptionTalent = Cat2.IsTalentLearned(1,2)
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("腐蚀术", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 30
    end

    local WarlockCorruptionDuration = 18

    -- 腐蚀术持续时间
    -- 这里有个等级问题，以后再考虑
    WarlockCorruptionDuration = tonumber(Cat2.Match(Cat2.GetSpellTooltip("腐蚀术","等级 1"), "腐蚀目标，在(%d+%.%d+)"))
    if not WarlockCorruptionDuration then WarlockCorruptionDuration=18 end

    Cat2.SetWarlockCorruptionDuration(WarlockCorruptionDuration)

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

    if CorruptionTalent>0 then

        -- 天赋减CD
        if not Cat2.GetCorruptionDot() then
            Cat2.CastWarlockDot(context, "腐蚀术")
            return true
        end

    else

        -- 读条的腐蚀术
        if not Cat2.GetCorruptionDot("target", 1.2) and (GetTime()-Cat2.GetCorruptionTimer())>0 then
            Cat2.CastWarlockDot(context, "腐蚀术")
            return true
        end

    end

    return false

end

Cat2.RegisterCard(card)
