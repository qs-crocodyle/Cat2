-- 圣骑士惩戒系普通卡：保持目标身上的光明审判。
local card = {
    id = "paladin_keep_light_judgement",
    name = "保持目标 光明审判",
    description = "保持目标身上的光明审判",
    details = "保持目标身上的光明审判。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 2,
    unique = true,
    exclusiveGroup = "paladin_judgement_maintenance",
    category = "class",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_HealingAura",
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


    if player.targetBuff["光明审判"] then
        return false
    end

    if not player.buff["光明圣印"] then
        CastSpellByName("光明圣印")
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
