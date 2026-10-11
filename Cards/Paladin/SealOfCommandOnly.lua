-- 命令圣印 技能卡片。
local card = {
    id = "paladin_seal_of_command_only",
    name = "命令圣印",
    description = "施放并保持|cff6bc7e0{spellRank}级|r命令圣印，不自动施放审判",
    details = "施放并保持命令圣印，本卡不自动施放审判。沿用圣印卡规则：启用维持审判卡时，先等待对应审判生效。成功执行时会阻断本轮后续卡片。圣印等级可设置为1–5，默认5级；该参数只影响命令圣印，不影响审判。未学习指定等级时使用最高已学习等级。",
    sort = 29,
    category = "class",
    exclusiveGroup = "paladin_seal_maintenance",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_InnerRage",
    },
    optionSchema = {
        { key = "spellRank", type = "number", label = "圣印等级", shortLabel = "级", unit = "级",
            default = 5, minimum = 1, maximum = 5 },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local spellRank = context:GetStepOption(step, "spellRank") or 5
    local rankText = "等级 " .. spellRank
    local sealSpell = "命令圣印"
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

    if not Cat2.Seal("命令圣印") then
        Cat2.Cast(sealSpell)
        return true
    end

    return false
end

Cat2.RegisterCard(card)
