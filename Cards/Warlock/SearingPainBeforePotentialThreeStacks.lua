-- 灼热之痛（三层释放潜力前）技能卡片；执行逻辑与原灼热之痛保持一致。
local card = {
    id = "warlock_searing_pain_before_potential_three_stacks",
    name = "灼热之痛（三层释放潜力前）",
    description = "宠物在未满三层释放潜力时，施放灼热之痛",
    details = "宠物在未满三层释放潜力时，施放灼热之痛，用于快速叠层。需要存在有效目标，有宠物；目标火焰免疫时不会施放。成功执行时会阻断本轮后续卡片。",
    sort = 39,
    category = "class",
    classes = {
        WARLOCK = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_SoulBurn",
        "Interface\\Icons\\ability_warlock_demonicpower",
    },
}

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("灼热之痛", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 30
    end
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 目标火焰免疫时，不再尝试施放火焰伤害技能。
    if Cat2.IsFireImmune() then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    if not UnitExists("pet") then
        return false
    end

    local applications = Cat2.GetDebuffApplications("Interface\\Icons\\ability_warlock_demonicpower")

    if applications>=3 then
        return false
    end

    local elapsed = GetTime() - Cat2.GetSearingPainTimerTimer()
    if elapsed<0.2 then
        return false
    end

    Cat2.Cast("灼热之痛")
    return true
end

Cat2.RegisterCard(card)
