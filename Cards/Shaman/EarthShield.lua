-- 大地之盾 技能卡片。
local card = {
    id = "shaman_earth_shield",
    name = "大地之盾",
    description = "施放大地之盾，同时只能持续一个盾",
    details = "施放大地之盾，同时只能持续一个盾。",
    sort = 51,
    exclusiveGroup = "shaman_shield",
    category = "class",
    classes = {
        SHAMAN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_SkinofEarth",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local AutoWaterShield = Cat2.CardRegistry.ById["shaman_auto_water_shield_mana"]

    if context:IsCardActive("shaman_auto_water_shield_mana")
        and AutoWaterShield
        and type(AutoWaterShield.GetCustomValue) == "function" then

        -- 自动水之护盾正在回蓝时，不切换为其他护盾。
        local value = AutoWaterShield.GetCustomValue(context)
        if value then
            return false
        end
    end

    local player = Cat2.PlayerInformation.temporary

    if not player.buff["大地之盾"] then
        Cat2.Cast("大地之盾")
        return
    end

    return false

end

Cat2.RegisterCard(card)
