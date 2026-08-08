-- 精神鞭笞（二段）技能卡片。
local card = {
    id = "priest_mind_flay_second",
    name = "精神鞭笞（二阶）",
    description = "对目标施放二阶精神鞭笞",
    details = "对目标施放二阶精神鞭笞。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 31,
    category = "class",
    classes = {
        PRIEST = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_SiphonMana",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if Cat2.GetPriestChanneledDuration()>0 then

        if Cat2.GetPriestMindFlayCount()>=2 then
            Cat2.Cast("精神鞭笞")
            return true
        end

    end

    return false

end

Cat2.RegisterCard(card)
