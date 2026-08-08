-- 冷血 技能卡片。
local card = {
    id = "rogue_cold_blood",
    name = "冷血",
    description = "在目标存在、可攻击且冷血可用时施放",
    details = "在目标存在、可攻击且冷血可用时施放。需要存在有效目标。会检查目标距离。会检查战斗状态。",
    sort = 1,
    category = "class",
    classes = {
        ROGUE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Ice_Lament",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,15)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end


    if Cat2.RogueColdBloodReady() and Cat2.TargetDistance() then
        CastSpellByName("冷血")
    end

    return false
end

Cat2.RegisterCard(card)
