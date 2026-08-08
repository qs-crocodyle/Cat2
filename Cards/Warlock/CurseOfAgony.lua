-- 痛苦诅咒 技能卡片。
local card = {
    id = "warlock_curse_of_agony",
    name = "痛苦诅咒",
    description = "保持并施放痛苦诅咒",
    details = "保持并施放痛苦诅咒。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 80,
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",
    },
}

function card.RefreshRuntimeData()

    local CurseAgonyDuration = 24

    CurseAgonyDuration = tonumber(Cat2.Match(Cat2.GetSpellTooltip("痛苦诅咒","等级 5"), "使其在(%d+%.%d+)"))
    if not CurseAgonyDuration then CurseAgonyDuration=24 end

    Cat2.SetCurseAgonyDuration(CurseAgonyDuration)

end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if not Cat2.GetCurseAgonyDot() then
        CastSpellByName("痛苦诅咒")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
