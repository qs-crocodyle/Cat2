-- 圣骑士惩戒系普通卡：保持目标身上的智慧审判。
local card = {
    id = "paladin_keep_wisdom_judgement",
    name = "保持目标 智慧审判",
    description = "保持目标身上的智慧审判",
    details = "保持目标身上的智慧审判。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 1,
    unique = true,
    exclusiveGroup = "paladin_judgement_maintenance",
    category = "class",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_RighteousnessAura",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end


    if player.targetBuff["智慧审判"] then
        return false
    end

    if not player.buff["智慧圣印"] then
        CastSpellByName("智慧圣印")
        return true
    else

        if Cat2.SpellReady("审判") and player.gcd<0.2 and Cat2.TargetDistance("target",10) then
            CastSpellByName("审判")
            return true
        end

    end

    return false
end

Cat2.RegisterCard(card)
