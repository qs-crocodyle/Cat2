-- 正义圣印 技能卡片。
local card = {
    id = "paladin_seal_of_righteousness_only",
    name = "正义圣印",
    description = "施放并保持正义圣印，不自动施放审判",
    details = "施放并保持正义圣印，本卡不自动施放审判。沿用圣印卡规则：启用维持审判卡时，先等待对应审判生效。成功执行时会阻断本轮后续卡片。",
    sort = 28,
    category = "class",
    exclusiveGroup = "paladin_seal_maintenance",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_ThunderBolt",
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

    if not Cat2.Seal("正义圣印") then
        Cat2.Cast("正义圣印")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
