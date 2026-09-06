-- 吸取法力 技能卡片。
local card = {
    id = "warlock_drain_mana",
    name = "吸取法力",
    description = "施放吸取法力",
    details = "施放吸取法力。需要存在有效目标。",
    sort = 110,
    exclusiveGroup = "warlock_drain_spell",
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_SiphonMana",
    },
}

local distance = 20

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("吸取法力", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 20
    end
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    -- 目标吸蓝条件
    if not Cat2.IsManaDrain() then
        return false
    end

    Cat2.Cast("吸取法力")
    return false -- 这里注意，需要与其他吸取不同，防止卡流程

end

Cat2.RegisterCard(card)
