-- 冲动强敌卡：仅在强敌目标条件下施放冲动。
local card = {
    id = "rogue_adrenaline_rush_boss",
    name = "冲动 仅强敌时",
    description = "强敌目标下，能量较低时施放冲动",
    details = "强敌目标下，能量较低时施放冲动。需要存在有效目标。会检查目标距离。会检查当前资源。仅在技能可用时尝试执行。",
    sort = 91,
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
    allowUse = Cat2.IsTalentLearned(2, 18)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists or not Cat2.IsBossTarget() then
        return false
    end


    if allowUse == 0 then
        return false
    end

    if player.power < 40 and Cat2.SpellReady("冲动") and Cat2.TargetDistance() then
        CastSpellByName("冲动")
    end

    return false
end

Cat2.RegisterCard(card)
