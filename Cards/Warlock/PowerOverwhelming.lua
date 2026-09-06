local card = {
    id = "warlock_power_overwhelming",
    name = "超越之力",
    description = "宠物生命>|cff6bc7e0{minimumPetHealthPercent}%|r时，强化当前召唤的恶魔",
    details = "宠物生命值严格高于卡片设定值时，强化当前召唤的恶魔。默认要求宠物生命值高于25%。需要宠物存在且能正确读取生命值。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 40,
    category = "class",
    classes = { WARLOCK = 2 },
    icons = { "Interface\\Icons\\Ability_Warlock_Power_Overwhelming" },
    cooldown = { type = "spell", name = "超越之力" },
    optionSchema = {
        {
            key = "minimumPetHealthPercent",
            type = "number",
            label = "宠物最低生命值",
            shortLabel = "宠血",
            unit = "%",
            default = 25,
            minimum = 0,
            maximum = 99,
        },
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(2,14)
end

function card.Execute(context, step)
    if allowUse==0 then
        return false
    end

    if not UnitExists("pet") then
        return false
    end

    local minimumPetHealthPercent = context:GetStepOption(step, "minimumPetHealthPercent") or 25
    local petHealth = UnitHealth("pet") or 0
    local petHealthMax = UnitHealthMax("pet") or 0
    if petHealthMax <= 0 or petHealth / petHealthMax * 100 <= minimumPetHealthPercent then
        return false
    end

    if Cat2.SpellReady("超越之力") then
        Cat2.Cast("超越之力")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
