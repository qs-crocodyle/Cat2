-- 生命分流（蓝量<30%）技能卡片。
local card = {
    id = "warlock_life_tap_30",
    name = "生命分流（蓝量<30%）",
    description = "蓝量<30%时，施放生命分流",
    details = "蓝量<30%时，施放生命分流。会检查相关生命值。成功执行时会阻断本轮后续卡片。",
    sort = 150,
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_BurningSpirit",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if player.percentMana<30.0 and player.health>400 then
        CastSpellByName("生命分流")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
