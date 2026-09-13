-- 暴风雪（目标）技能卡片；具体执行逻辑待补充。
local card = {
    id = "mage_blizzard_target",
    name = "暴风雪（目标）",
    description = "以目标为施法位置使用|cff6bc7e0{spellRank}级|r暴风雪",
    details = "按卡片设定等级，以目标为施法位置使用暴风雪；默认动态使用当前已学习的最高等级，需UnitXP202607以上。成功执行时会阻断本轮后续卡片。",
    sort = 40.2,
    category = "class",
    exclusiveGroup = "mage_blizzard",
    classes = {
        MAGE = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_IceStorm",
    },
    optionSchema = { Cat2.CreateSpellRankOption("暴风雪") },
}

local allowUse = 0

function card.RefreshRuntimeData()

    if Cat2.UnitXP then

        local compileTime = UnitXP("version", "coffTimeDateStamp")
        if compileTime>=1782864000 then
            allowUse = 1
        end

    end

end

function card.Execute(context, step)

    -- 不存在这个模组
    if allowUse==0 then
        DEFAULT_CHAT_FRAME:AddMessage(Cat2.L("|cffff8000当前UnitXP模组版本不支持！|r"))
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    local spellRank = context:GetStepOption(step, "spellRank")
    local rankedSpellName = Cat2.GetRankedSpellName("暴风雪", spellRank) or "暴风雪"
    Cat2.Cast(rankedSpellName)
    UnitXP("castAOE", "target")

    return true
end

Cat2.RegisterCard(card)
