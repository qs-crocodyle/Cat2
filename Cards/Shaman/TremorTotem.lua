-- 战栗图腾 技能卡片。
local card = {
    id = "shaman_tremor_totem",
    name = "战栗图腾",
    description = "保持并施放战栗图腾",
    details = "保持并施放战栗图腾。",
    sort = 40,
    exclusiveGroup = "shaman_earth_totem",
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_TremorTotem",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    -- 图腾是否存在
    if not Cat2.EarthTotem() then
        CastSpellByName("战栗图腾")
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.EarthTotemName() ~= "战栗图腾" then
            CastSpellByName("战栗图腾")
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
