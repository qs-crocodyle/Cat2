-- 石爪图腾 技能卡片。
local card = {
    id = "shaman_stoneclaw_totem",
    name = "石爪图腾",
    description = "保持并施放石爪图腾",
    details = "保持并施放石爪图腾。",
    sort = 30,
    exclusiveGroup = "shaman_earth_totem",
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_StoneClawTotem",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    -- 图腾是否存在
    if not Cat2.EarthTotem() then
        CastSpellByName("石爪图腾")
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.EarthTotemName() ~= "石爪图腾" then
            CastSpellByName("石爪图腾")
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
