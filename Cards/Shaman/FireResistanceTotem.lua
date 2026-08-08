-- 抗火图腾 技能卡片。
local card = {
    id = "shaman_fire_resistance_totem",
    name = "抗火图腾",
    description = "保持并施放抗火图腾",
    details = "保持并施放抗火图腾。",
    sort = 110,
    exclusiveGroup = "shaman_water_totem",
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_FireResistanceTotem_01",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    -- 图腾是否存在
    if not Cat2.WaterTotem() then
        CastSpellByName("抗火图腾")
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.WaterTotemName() ~= "抗火图腾" then
            CastSpellByName("抗火图腾")
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
