-- 智慧圣印 技能卡片。
local card = {
    id = "paladin_seal_of_wisdom",
    name = "智慧圣印",
    description = "施放并保持智慧圣印",
    details = "施放并保持智慧圣印。成功执行时会阻断本轮后续卡片。",
    sort = 50,
    category = "class",
    exclusiveGroup = "paladin_seal_maintenance",
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


    if not player.buff["智慧圣印"] then
        CastSpellByName("智慧圣印")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
