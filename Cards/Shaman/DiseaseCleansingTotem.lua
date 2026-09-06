-- 祛病图腾 技能卡片。
local card = {
    id = "shaman_disease_cleansing_totem",
    name = "祛病图腾",
    description = "保持并施放|cff6bc7e0{spellRank}级|r祛病图腾",
    details = "保持并施放祛病图腾。",
    sort = 150,
    exclusiveGroup = "shaman_water_totem",
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_DiseaseCleansingTotem",
    },
    optionSchema = { Cat2.CreateSpellRankOption("祛病图腾") },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local spellRank = context:GetStepOption(step, "spellRank")

    -- 图腾是否存在
    if not Cat2.WaterTotem() then
        Cat2.CastRankedWithNampower("祛病图腾", spellRank)
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.WaterTotemName() ~= "祛病图腾" then
            Cat2.CastRankedWithNampower("祛病图腾", spellRank)
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
