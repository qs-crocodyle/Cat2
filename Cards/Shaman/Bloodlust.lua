-- 嗜血 技能卡片。
local card = {
    id = "shaman_bloodlust",
    name = "嗜血",
    description = "在近战距离内，技能冷却时，施放嗜血",
    details = "在近战距离内，技能冷却时，施放嗜血。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 70,
    category = "class",
    classes = {
        SHAMAN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_BloodLust",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(2, 16)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    -- 未学习嗜血天赋时不执行。
    if allowUse == 0 then
        return false
    end

    if Cat2.SpellReady("嗜血") and Cat2.TargetDistance() then
        CastSpellByName("嗜血")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
