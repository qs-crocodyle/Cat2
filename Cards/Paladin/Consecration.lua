-- 奉献 技能卡片。
local card = {
    id = "paladin_consecration",
    name = "奉献",
    description = "蓝量>|cff6bc7e0{manaThreshold}%|r且在近战范围时，施放|cff6bc7e0{spellRank}级|r奉献",
    details = "蓝量严格高于设定百分比且在近战范围时，按卡片设定等级施放奉献；蓝量阈值默认1%。默认动态使用当前已学习的最高等级。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 110,
    category = "class",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_InnerFire",
    },
    cooldown = {
        type = "spell",
        name = "奉献",
    },
    optionSchema = {
        Cat2.CreateSpellRankOption("奉献"),
        {
            key = "manaThreshold",
            type = "number",
            label = "蓝量高于",
            shortLabel = "蓝",
            unit = "%",
            default = 1,
            minimum = 0,
            maximum = 100,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local spellRank = context:GetStepOption(step, "spellRank")

    local player = Cat2.PlayerInformation.temporary
    local manaThreshold = context:GetStepOption(step, "manaThreshold") or 1
    if player.percentMana <= manaThreshold then
        return false
    end

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end


    -- 近战距离
    if not Cat2.TargetDistance() then
        return false
    end

    if Cat2.SpellReady("奉献") then
        local rankedSpellName = Cat2.GetRankedSpellName("奉献", spellRank) or "奉献"
        Cat2.Cast(rankedSpellName)
        return true
    end

    return false
end

Cat2.RegisterCard(card)
