-- 生命虹吸 技能卡片。
local card = {
    id = "warlock_siphon_life",
    name = "生命虹吸",
    description = "对目标保持并施放生命虹吸",
    details = "对目标保持并施放生命虹吸。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 130,
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_Requiem",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()

    allowUse = Cat2.IsTalentLearned(1,14)

    local WarlockSiphonLifeDuration = 30

    -- 生命虹吸持续时间
    WarlockSiphonLifeDuration = tonumber(Cat2.Match(Cat2.GetSpellTooltip("生命虹吸","等级 1"), "在(%d+%.%d+)"))
    if not WarlockSiphonLifeDuration then WarlockSiphonLifeDuration=30 end

    Cat2.SetWarlockSiphonLifeDuration(WarlockSiphonLifeDuration)

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

    if not Cat2.GetSiphonLifeDot() then
        CastSpellByName("生命虹吸")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
