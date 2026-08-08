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
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end


    if Cat2.SpellReady("制裁之锤") and Cat2.TargetDistance("target",10) then
        CastSpellByName("制裁之锤")
        return true
    end


    return false
end

Cat2.RegisterCard(card)