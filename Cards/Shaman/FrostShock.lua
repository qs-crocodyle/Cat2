-- 冰霜震击 技能卡片。
local card = {
    id = "shaman_frost_shock",
    name = "冰霜震击",
    description = "冷却时，施放冰霜震击",
    details = "冷却时，施放冰霜震击。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 50,
    category = "class",
    exclusiveGroup = "shaman_shock",
    classes = {
        SHAMAN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_FrostShock",
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

    -- 有unitxp模组，用于射程过滤
    if Cat2.UnitXP then
        local range = UnitXP("distanceBetween", "player", "target")
        if range>20 then
            return false
        end
    end

    if Cat2.SpellReadyOffset("冰霜震击",1.5) then
        CastSpellByName("冰霜震击")
        return true
    end

end

Cat2.RegisterCard(card)
