-- 法力之泉图腾 技能卡片。
local card = {
    id = "shaman_mana_spring_totem",
    name = "法力之泉图腾",
    description = "保持并施放法力之泉图腾",
    details = "保持并施放法力之泉图腾。",
    sort = 130,
    exclusiveGroup = "shaman_water_totem",
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_ManaRegenTotem",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    -- 图腾是否存在
    if not Cat2.WaterTotem() then
        CastSpellByName("法力之泉图腾")
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.WaterTotemName() ~= "法力之泉图腾" then
            CastSpellByName("法力之泉图腾")
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
