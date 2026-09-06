-- 生命虹吸 技能卡片。
local card = {
    id = "warlock_siphon_life",
    name = "生命虹吸",
    description = "对目标保持并施放生命虹吸",
    details = "对目标保持并施放生命虹吸。需要存在有效目标；目标暗影免疫时不会施放。成功执行时会阻断本轮后续卡片。",
    sort = 91,
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_Requiem",
    },
}

local allowUse = 0
local distance = 30

function card.RefreshRuntimeData()

    allowUse = Cat2.IsTalentLearned(1,14)
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("生命虹吸", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 30
    end

    local WarlockSiphonLifeDuration = 30

    -- 生命虹吸持续时间
    WarlockSiphonLifeDuration = tonumber(Cat2.Match(Cat2.GetSpellTooltip("生命虹吸","等级 1"), "在(%d+%.%d+)"))
    if not WarlockSiphonLifeDuration then WarlockSiphonLifeDuration=30 end

    Cat2.SetWarlockSiphonLifeDuration(WarlockSiphonLifeDuration)

end

function card.Execute(context)

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

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

    -- 目标吸血条件
    if not Cat2.IsDrain() then
        return false
    end

    if not Cat2.GetSiphonLifeDot() then
        Cat2.CastWarlockDot(context, "生命虹吸")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
