-- 精神鞭笞 技能卡片。
local card = {
    id = "priest_mind_flay",
    name = "精神鞭笞",
    description = "对目标施放精神鞭笞",
    details = "对目标施放精神鞭笞。需要存在有效目标；目标暗影免疫时不会施放。",
    sort = 30,
    category = "class",
    classes = {
        PRIEST = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_SiphonMana",
    },
}

local distance = 20

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("精神鞭笞", "等级 1"), "(%d+)码距离"))
    if not distance then distance = 20 end
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

    Cat2.Cast("精神鞭笞")

    return false
end

Cat2.RegisterCard(card)
