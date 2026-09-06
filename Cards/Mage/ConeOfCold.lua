-- 冰锥术 技能卡片。
local card = {
    id = "mage_cone_of_cold",
    name = "冰锥术",
    description = "有效距离内，冷却后施放|cff6bc7e0{spellRank}级|r冰锥术",
    details = "有效距离内，冷却后按卡片设定等级施放冰锥术；未学习指定等级时，直接施放冰锥术并由游戏选择最高已学习等级。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 40,
    category = "class",
    classes = {
        MAGE = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_Glacier",
    },
    cooldown = {
        type = "spell",
        name = "冰锥术",
    },
    optionSchema = {
        {
            key = "spellRank",
            type = "number",
            label = "技能等级",
            shortLabel = "级",
            unit = "级",
            default = 5,
            minimum = 1,
            maximum = 5,
        },
    },
}

local range = 8

function card.RefreshRuntimeData()
    allowUse = 8 + Cat2.IsTalentLearned(3,11)
end

function card.Execute(context, step)

    local spellRank = context:GetStepOption(step, "spellRank") or 5

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    -- 有效射程
    if not Cat2.TargetDistance("target", range) then
        return false
    end

    if Cat2.SpellReady("冰锥术") then  -- 可以增加保护 not player.buff["冰霜速冻"]
        local rankText = "等级 " .. spellRank
        if Cat2.GetSpellID("冰锥术", rankText)>0 then
            Cat2.Cast("冰锥术(" .. rankText .. ")")
        else
            -- 未学习指定等级时，不附加等级，让游戏自动选择最高已学习等级。
            Cat2.Cast("冰锥术")
        end
        return true
    end

    return false

end

Cat2.RegisterCard(card)
