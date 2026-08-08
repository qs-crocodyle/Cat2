-- 清毒图腾 技能卡片。
local card = {
    id = "shaman_poison_cleansing_totem",
    name = "清毒图腾",
    description = "保持并施放清毒图腾",
    details = "保持并施放清毒图腾。",
    sort = 140,
    exclusiveGroup = "shaman_water_totem",
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_PoisonCleansingTotem",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    -- 图腾是否存在
    if not Cat2.WaterTotem() then
        CastSpellByName("清毒图腾")
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.WaterTotemName() ~= "清毒图腾" then
            CastSpellByName("清毒图腾")
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
