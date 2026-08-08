-- 宁静之风图腾 技能卡片。
local card = {
    id = "shaman_tranquil_air_totem",
    name = "宁静之风图腾",
    description = "保持并施放宁静之风图腾",
    details = "保持并施放宁静之风图腾。",
    sort = 210,
    exclusiveGroup = "shaman_air_totem",
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_Brilliance",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    -- 图腾是否存在
    if not Cat2.AirTotem() then
        CastSpellByName("宁静之风图腾")
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.AirTotemName() ~= "宁静之风图腾" then
            CastSpellByName("宁静之风图腾")
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
