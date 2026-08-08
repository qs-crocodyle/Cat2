-- 嗜血 技能卡片。
local card = {
    id = "warrior_bloodthirst",
    name = "嗜血",
    description = "冷却好时，施放嗜血",
    details = "冷却好时，施放嗜血。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 130,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_BloodLust",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    if player.power>=30 and Cat2.SpellReady("嗜血") then
        CastSpellByName("嗜血")
        return true
    end

end

Cat2.RegisterCard(card)