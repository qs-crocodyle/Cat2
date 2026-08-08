-- 风怒图腾 技能卡片。
local card = {
    id = "shaman_windfury_totem",
    name = "风怒图腾",
    description = "保持并施放风怒图腾",
    details = "保持并施放风怒图腾。",
    sort = 200,
    exclusiveGroup = "shaman_air_totem",
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_Windfury",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    -- 图腾是否存在
    if not Cat2.AirTotem() then
        CastSpellByName("风怒图腾")
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.AirTotemName() ~= "风怒图腾" then
            CastSpellByName("风怒图腾")
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
