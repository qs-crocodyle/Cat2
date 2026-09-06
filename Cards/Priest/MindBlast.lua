-- 心灵震爆 技能卡片。
local card = {
    id = "priest_mind_blast",
    name = "心灵震爆",
    description = "冷却后，施放心灵震爆",
    details = "冷却后，施放心灵震爆。需要存在有效目标；目标暗影免疫时不会施放。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 10,
    category = "class",
    classes = {
        PRIEST = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
    },
    cooldown = {
        type = "spell",
        name = "心灵震爆",
    },
}

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("心灵震爆", "等级 1"), "(%d+)码距离"))
    if not distance then distance = 30 end
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

    if Cat2.SpellReady("心灵震爆") then
        Cat2.Cast("心灵震爆")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
