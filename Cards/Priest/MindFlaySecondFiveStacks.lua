-- 精神鞭笞（二阶 仅五层易伤）技能卡片。
local card = {
    id = "priest_mind_flay_second_five_stacks",
    name = "精神鞭笞（二阶 仅五层易伤）",
    description = "易伤五层前，对目标施放二阶精神鞭笞",
    details = "可独立使用：未在施法或引导时启动精神鞭笞；暗影易伤不足五层时，引导造成第二跳伤害后中断并重新施放，达到五层后让引导正常完成。需要存在有效目标；目标暗影免疫或超出射程时不会施放。成功执行时会阻断本轮后续卡片。",
    sort = 32,
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

        if Cat2.GetPriestMindFlayCount()>=2 and Cat2.GetBuffApplications("Interface\\Icons\\Spell_Shadow_BlackPlague")<5 then
            SpellStopCasting()
            CastSpellByName("精神鞭笞")
            return true
        end

    end

    return false

end

Cat2.RegisterCard(card)
