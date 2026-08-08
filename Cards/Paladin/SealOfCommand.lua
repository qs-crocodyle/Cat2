-- 命令圣印 技能卡片。
local card = {
    id = "paladin_seal_of_command",
    name = "保持命令圣印/审判",
    description = "保持命令圣印的同时，施放审判进行攻击",
    details = "保持命令圣印的同时，施放审判进行攻击。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 20,
    category = "class",
    exclusiveGroup = "paladin_seal_maintenance",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_InnerRage",
        "Interface\\Icons\\Spell_Holy_RighteousFury",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary


    -- 正义审判
    if context:IsCardActive("paladin_keep_justice_judgement") then
        if not player.targetBuff["正义审判"] then
            return false
        end
    end

    -- 光明审判
    if context:IsCardActive("paladin_keep_light_judgement") then
        if not player.targetBuff["光明审判"] then
            return false
        end
    end

    -- 智慧审判
    if context:IsCardActive("paladin_keep_wisdom_judgement") then
        if not player.targetBuff["智慧审判"] then
            return false
        end
    end

    -- 十字军审判
    if context:IsCardActive("paladin_keep_crusader_judgement") then
        if not player.targetBuff["十字军审判"] then
            return false
        end
    end

    -- 执行圣印卡片内容

    if not player.buff["命令圣印"] then
        CastSpellByName("命令圣印")
        return true
    else

        -- 没目标就无需继续
        if not player.targetExists then
            return false
        end

        if Cat2.SpellReady("审判") and player.gcd<0.2 and Cat2.TargetDistance("target",10) then
            CastSpellByName("审判")
            return true
        end

    end

    return false
end

Cat2.RegisterCard(card)
