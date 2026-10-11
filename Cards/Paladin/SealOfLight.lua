-- 光明圣印 技能卡片。
local card = {
    id = "paladin_seal_of_light",
    name = "光明圣印",
    description = "施放并保持|cff6bc7e0{spellRank}级|r光明圣印",
    details = "施放并保持光明圣印。成功执行时会阻断本轮后续卡片。圣印等级可设置为1–4，默认4级；该参数只影响光明圣印，不影响审判。未学习指定等级时使用最高已学习等级。",
    sort = 40,
    category = "class",
    exclusiveGroup = "paladin_seal_maintenance",
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

    if not Cat2.Seal("光明圣印") then
        Cat2.Cast(sealSpell)
        return true
    end

    return false
end

Cat2.RegisterCard(card)
