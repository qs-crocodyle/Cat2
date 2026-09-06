-- 大地之力图腾 技能卡片。
local card = {
    id = "shaman_strength_of_earth_totem",
    name = "大地之力图腾",
    description = "保持并施放|cff6bc7e0{spellRank}级|r大地之力图腾",
    details = "保持并施放大地之力图腾。",
    sort = 10,
    exclusiveGroup = "shaman_earth_totem",
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_EarthBindTotem",
    },
    optionSchema = { Cat2.CreateSpellRankOption("大地之力图腾") },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local spellRank = context:GetStepOption(step, "spellRank")

    -- 图腾是否存在
    if not Cat2.EarthTotem() then
        Cat2.CastRankedWithNampower("大地之力图腾", spellRank)
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.EarthTotemName() ~= "大地之力图腾" then
            Cat2.CastRankedWithNampower("大地之力图腾", spellRank)
            return false
        end
    end

    return false
end

Cat2.RegisterCard(card)
