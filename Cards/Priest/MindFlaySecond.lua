-- 精神鞭笞（二段）技能卡片。
local card = {
    id = "priest_mind_flay_second",
    name = "精神鞭笞（二阶）",
    description = "对目标施放二阶精神鞭笞",
    details = "可独立使用：未在施法或引导时启动精神鞭笞；引导造成第二跳伤害后，中断当前引导并重新施放。需要存在有效目标；目标暗影免疫或超出射程时不会施放。成功执行时会阻断本轮后续卡片。",
    sort = 31,
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

    if Cat2.GetChanneledDuration() <= 0 then
        if not Cat2.GetIsCast() and Cat2.SpellReady("精神鞭笞") then
            Cat2.Cast("精神鞭笞")
            return true
        end
        return false
    end

    if Cat2.SpellReady("精神鞭笞") then

        if Cat2.GetPriestMindFlayCount()>=2 then
            SpellStopCasting()
            CastSpellByName("精神鞭笞")
            return true
        end

    end

    return false

end

Cat2.RegisterCard(card)
