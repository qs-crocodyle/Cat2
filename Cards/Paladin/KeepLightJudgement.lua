-- 圣骑士惩戒系普通卡：保持目标身上的光明审判。
local card = {
    id = "paladin_keep_light_judgement",
    name = "保持目标 光明审判",
    description = "使用|cff6bc7e0{spellRank}级|r光明圣印，保持目标身上的光明审判",
    details = "保持目标身上的光明审判。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。圣印等级可设置为1–4，默认4级；该参数只影响光明圣印，不影响审判。未学习指定等级时使用最高已学习等级。",
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
    optionSchema = {
        { key = "spellRank", type = "number", label = "圣印等级", shortLabel = "级", unit = "级",
            default = 4, minimum = 1, maximum = 4 },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local spellRank = context:GetStepOption(step, "spellRank") or 4
    local rankText = "等级 " .. spellRank
    local sealSpell = "光明圣印"
    if Cat2.GetSpellID(sealSpell, rankText) > 0 then
        sealSpell = sealSpell .. "(" .. rankText .. ")"
    end

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end


    if player.targetBuff["光明审判"] then
        return false
    end

    if not player.buff["光明圣印"] then
        Cat2.Cast(sealSpell)
        return true
    else

        if Cat2.SpellReady("审判") and player.gcd<0.2 and Cat2.TargetDistance("target",10) then
            Cat2.Cast("审判")
            return true
        end

    end

    return false
end

Cat2.RegisterCard(card)
