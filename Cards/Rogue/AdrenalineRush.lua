-- 冲动 技能卡片。
local card = {
    id = "rogue_adrenaline_rush",
    name = "冲动",
    description = "技能冷却后，能量<40时施放冲动",
    details = "技能冷却后，能量<40时施放冲动。需要存在有效目标。会检查目标距离。会检查当前资源。仅在技能可用时尝试执行。",
    sort = 90,
    category = "class",
    classes = {
        ROGUE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(2,18)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    if player.power<40 and Cat2.SpellReady("冲动") and Cat2.TargetDistance() then
        CastSpellByName("冲动")
    end

    return false
end

Cat2.RegisterCard(card)