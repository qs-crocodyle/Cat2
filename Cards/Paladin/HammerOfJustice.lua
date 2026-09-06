-- 制裁之锤 技能卡片。
local card = {
    id = "paladin_hammer_of_justice",
    name = "制裁之锤",
    description = "冷却好时，对目标施放制裁之锤",
    details = "冷却好时，对目标施放制裁之锤。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 100,
    category = "class",
    classes = {
        PALADIN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_SealOfMight",
    },
    cooldown = {
        type = "spell",
        name = "制裁之锤",
    },
}

local distance = 10

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("制裁之锤", "等级 1"), "(%d+)码距离"))
    if not distance then distance = 10 end
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    if Cat2.SpellReady("制裁之锤") then
        Cat2.Cast("制裁之锤")
        return true
    end


    return false
end

Cat2.RegisterCard(card)
