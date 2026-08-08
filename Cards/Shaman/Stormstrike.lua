-- 风暴打击 技能卡片。
local card = {
    id = "shaman_stormstrike",
    name = "风暴打击",
    description = "冷却时，施放风暴打击",
    details = "冷却时，施放风暴打击。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 55,
    category = "class",
    classes = {
        SHAMAN = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Shaman_StormStrike",
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

    if Cat2.SpellReady("风暴打击") then
        CastSpellByName("风暴打击")
        return true
    end

end

Cat2.RegisterCard(card)
