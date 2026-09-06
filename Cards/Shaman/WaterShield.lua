-- 水之护盾 技能卡片。
local card = {
    id = "shaman_water_shield",
    name = "水之护盾",
    description = "施放水之护盾，同时只能持续一个盾",
    details = "施放水之护盾，同时只能持续一个盾。",
    sort = 52,
    exclusiveGroup = "shaman_shield",
    category = "class",
    classes = {
        SHAMAN = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Shaman_WaterShield",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local AutoWaterShield = Cat2.CardRegistry.ById["shaman_auto_water_shield_mana"]

    if context:IsCardActive("shaman_auto_water_shield_mana")
        and AutoWaterShield
        and type(AutoWaterShield.GetCustomValue) == "function" then

        -- 自动水之护盾正在回蓝时，普通水之护盾交由自动卡维持。
        local value = AutoWaterShield.GetCustomValue(context)
        if value then
            return false
        end
    end

    local player = Cat2.PlayerInformation.temporary

    if not player.buff["水之护盾"] then
        Cat2.Cast("水之护盾")
        return
    end

    return false

end

Cat2.RegisterCard(card)
