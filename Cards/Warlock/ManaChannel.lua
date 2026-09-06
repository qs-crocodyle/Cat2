-- 法力通道技能卡片。
local card = {
    id = "warlock_mana_channel",
    name = "法力通道",
    description = "宠物法力<|cff6bc7e0{petManaPercent}%|r时，施放法力通道",
    details = "宠物法力低于卡片设定值时，施放法力通道。默认触发值为30%。需要宠物存在且能正确读取法力值。成功执行时会阻断本轮后续卡片。",
    sort = 35,
    category = "class",
    classes = {
        WARLOCK = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_SiphonMana",
    },
    optionSchema = {
        {
            key = "petManaPercent",
            type = "number",
            label = "宠物法力值",
            shortLabel = "宠蓝",
            unit = "%",
            default = 30,
            minimum = 1,
            maximum = 99,
        },
    },
}

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("法力通道", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 30
    end
end

function card.Execute(context, step)

    local petManaPercent = context:GetStepOption(step, "petManaPercent") or 30

    if not UnitExists("pet") then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "pet")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    local petMana = UnitMana("pet") or 0
    local petManaMax = UnitManaMax("pet") or 0
    if petManaMax <= 0 then
        return false
    end

    if petMana / petManaMax * 100 < petManaPercent then
        Cat2.Cast("法力通道")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
