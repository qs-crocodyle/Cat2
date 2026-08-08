-- 暗影诅咒（邪咒）技能卡片。
local card = {
    id = "warlock_curse_of_shadow_hex",
    name = "暗影诅咒（邪咒）",
    description = "保持并施放暗影诅咒和痛苦诅咒",
    details = "保持并施放暗影诅咒和痛苦诅咒。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 35,
    exclusiveGroup = "warlock_major_curse",
    category = "class",
    classes = { WARLOCK = 1 },
    icons = { "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde",
        "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()

    allowUse = Cat2.IsTalentLearned(1,16)

    local CurseAgonyDuration = 24

    CurseAgonyDuration = tonumber(Cat2.Match(Cat2.GetSpellTooltip("痛苦诅咒","等级 5"), "使其在(%d+%.%d+)"))
    if not CurseAgonyDuration then CurseAgonyDuration=24 end

    Cat2.SetCurseAgonyDuration(CurseAgonyDuration)
end

function card.Execute(context)

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if not player.targetBuff["暗影诅咒"] or not Cat2.GetCurseAgonyDot() then
        CastSpellByName("暗影诅咒")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
