-- 寒冰护体（冰冷血脉）技能卡片；执行机制与原寒冰护体一致。
local card = {
    id = "mage_ice_barrier_icy_veins",
    name = "寒冰护体（冰冷血脉）",
    description = "冰冷血脉消失后，施放|cff6bc7e0{spellRank}级|r寒冰护体",
    details = "冰冷血脉消失后，按卡片设定等级施放寒冰护体；未学习指定等级时，直接施放寒冰护体并由游戏选择最高已学习等级。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 42,
    category = "class",
    classes = {
        MAGE = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Ice_Lament",
    },
    cooldown = {
        type = "spell",
        name = "寒冰护体",
    },
    optionSchema = {
        {
            key = "spellRank",
            type = "number",
            label = "技能等级",
            shortLabel = "级",
            unit = "级",
            default = 4,
            minimum = 1,
            maximum = 4,
        },
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(3,19)
end

function card.Execute(context, step)

    local spellRank = context:GetStepOption(step, "spellRank") or 4

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    if Cat2.SpellReady("寒冰护体") and not player.buff["冰冷血脉"] then
        local rankText = "等级 " .. spellRank
        if Cat2.GetSpellID("寒冰护体", rankText)>0 then
            Cat2.Cast("寒冰护体(" .. rankText .. ")")
        else
            -- 未学习指定等级时，不附加等级，让游戏自动选择最高已学习等级。
            Cat2.Cast("寒冰护体")
        end
        return true
    end

    return false

end

Cat2.RegisterCard(card)
