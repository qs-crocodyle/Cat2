-- 生命通道 技能卡片。
local card = {
    id = "warlock_health_funnel",
    name = "生命通道",
    description = "宠物生命<|cff6bc7e0{petHealthPercent}%|r时，施放生命通道",
    details = "宠物生命低于卡片设定值时，施放生命通道。默认触发值为30%。需要宠物存在且能正确读取生命值。成功执行时会阻断本轮后续卡片。",
    sort = 30,
    category = "class",
    classes = {
        WARLOCK = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_LifeDrain",
    },
    optionSchema = {
        {
            key = "petHealthPercent",
            type = "number",
            label = "宠物生命值",
            shortLabel = "宠",
            unit = "%",
            default = 30,
            minimum = 1,
            maximum = 99,
        },
    },
}

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("生命通道", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 30
    end
end

function card.Execute(context, step)

    local petHealthPercent = context:GetStepOption(step, "petHealthPercent") or 30

    if not UnitExists("pet") then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "pet")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    local petHealth = UnitHealth("pet") or 0
    local petHealthMax = UnitHealthMax("pet") or 0
    if petHealthMax <= 0 then
        return false
    end

    if petHealth / petHealthMax * 100 < petHealthPercent then
        Cat2.Cast("生命通道")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
