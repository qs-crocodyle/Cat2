-- 惩击 技能卡片。
local card = {
    id = "priest_smite",
    name = "惩击",
    description = "施放惩击，适合做填充技能",
    details = "施放惩击，适合做填充技能。",
    sort = 40,
    category = "class",
    classes = {
        PRIEST = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_HolySmite",
    },
}

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("惩击", "等级 1"), "(%d+)码距离"))
    if not distance then distance = 30 end
end

function card.Execute(context)
    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    Cat2.Cast("惩击")
    return false
end

Cat2.RegisterCard(card)
