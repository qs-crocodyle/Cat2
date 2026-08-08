-- 火舌图腾 技能卡片。
local card = {
    id = "shaman_flametongue_totem",
    name = "火舌图腾",
    description = "保持并施放火舌图腾",
    details = "保持并施放火舌图腾。",
    sort = 100,
    exclusiveGroup = "shaman_fire_totem",
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_GuardianWard",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    -- 图腾是否存在
    if not Cat2.FireTotem() then
        CastSpellByName("火舌图腾")
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.FireTotemName() ~= "火舌图腾" then
            CastSpellByName("火舌图腾")
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
