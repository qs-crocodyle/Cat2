-- 震荡猛击 技能卡片。
local card = {
    id = "warrior_concussion_blow",
    name = "震荡猛击",
    description = "冷却好时，施放震荡猛击",
    details = "冷却好时，施放震荡猛击。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 110,
    category = "class",
    classes = {
        WARRIOR = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_ThunderBolt",
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

    if Cat2.SpellReady("震荡猛击") then
        CastSpellByName("震荡猛击")
        return true
    end

end

Cat2.RegisterCard(card)