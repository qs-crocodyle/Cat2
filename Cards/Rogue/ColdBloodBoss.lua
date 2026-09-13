-- 冷血强敌卡：仅在强敌目标条件下施放冷血。
local card = {
    id = "rogue_cold_blood_boss",
    name = "冷血 仅强敌时",
    description = "强敌目标下，连击点数>=|cff6bc7e0{minimumComboPoints}|r且冷血可用时施放",
    details = "强敌目标下，连击点数达到或超过设定值时施放冷血，参数为0至5的整数，默认0。需要存在有效目标。会检查天赋、技能可用状态、目标距离和战斗状态。",
    sort = 2,
    category = "class",
    classes = {
        ROGUE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Ice_Lament",
    },
    cooldown = {
        type = "spell",
        name = "冷血",
    },
    optionSchema = {
        {
            key = "minimumComboPoints",
            type = "number",
            label = "连击点数",
            shortLabel = "连击",
            default = 0,
            minimum = 0,
            maximum = 5,
            integer = true,
        },
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1, 15)
end

function card.Execute(context, step)

    if not Cat2.IsBossTarget() then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists or not player.inCombat then
        return false
    end


    if allowUse == 0 then
        return false
    end

    local minimumComboPoints = context:GetStepOption(step, "minimumComboPoints") or 0
    if player.targetCombo < minimumComboPoints then
        return false
    end

    if Cat2.RogueColdBloodReady() and Cat2.TargetDistance() then
        Cat2.Cast("冷血")
    end

    return false
end

Cat2.RegisterCard(card)
