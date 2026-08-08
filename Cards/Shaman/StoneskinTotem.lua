-- 石肤图腾 技能卡片。
local card = {
    id = "shaman_stoneskin_totem",
    name = "石肤图腾",
    description = "保持并施放石肤图腾",
    details = "保持并施放石肤图腾。",
    sort = 20,
    exclusiveGroup = "shaman_earth_totem",
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_StoneSkinTotem",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    -- 图腾是否存在
    if not Cat2.EarthTotem() then
        CastSpellByName("石肤图腾")
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.EarthTotemName() ~= "石肤图腾" then
            CastSpellByName("石肤图腾")
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
