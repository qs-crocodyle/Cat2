-- 驱邪术 技能卡片。
local card = {
    id = "paladin_exorcism",
    name = "驱邪术",
    description = "当目标是亡灵或恶魔时，施放驱邪术",
    details = "当目标是亡灵或恶魔时，施放驱邪术。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 130,
    category = "class",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_Excorcism_02",
    },
    cooldown = {
        type = "spell",
        name = "驱邪术",
    },
}

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("驱邪术", "等级 1"), "(%d+)码距离"))
    if not distance then distance = 30 end
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end

    if not player.targetCreatureType then
        return false
    end

    local typeA = string.find( player.targetCreatureType, "亡灵")
    local typeB = string.find( player.targetCreatureType, "恶魔")

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    -- 目标类型
	if typeA or typeB then
        if Cat2.SpellReady("驱邪术") then
            Cat2.Cast("驱邪术")
            return true
        end
    end


    return false
end

Cat2.RegisterCard(card)
