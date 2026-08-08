-- 治疗之泉图腾 技能卡片。
local card = {
    id = "shaman_healing_stream_totem",
    name = "治疗之泉图腾",
    description = "保持并施放治疗之泉图腾",
    details = "保持并施放治疗之泉图腾。",
    sort = 120,
    exclusiveGroup = "shaman_water_totem",
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\INV_Spear_04",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    -- 图腾是否存在
    if not Cat2.WaterTotem() then
        CastSpellByName("治疗之泉图腾")
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.WaterTotemName() ~= "治疗之泉图腾" then
            CastSpellByName("治疗之泉图腾")
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
