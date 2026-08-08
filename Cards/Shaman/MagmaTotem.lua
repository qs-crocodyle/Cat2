-- 熔岩图腾 技能卡片。
local card = {
    id = "shaman_magma_totem",
    name = "熔岩图腾",
    description = "保持并施放熔岩图腾",
    details = "保持并施放熔岩图腾。",
    sort = 80,
    exclusiveGroup = "shaman_fire_totem",
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_SelfDestruct",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    -- 图腾是否存在
    if not Cat2.FireTotem() then
        CastSpellByName("熔岩图腾")
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.FireTotemName() ~= "熔岩图腾" then
            CastSpellByName("熔岩图腾")
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
