-- 风之优雅图腾 技能卡片。
local card = {
    id = "shaman_grace_of_air_totem",
    name = "风之优雅图腾",
    description = "保持并施放|cff6bc7e0{spellRank}级|r风之优雅图腾",
    details = "保持并施放风之优雅图腾。",
    sort = 180,
    exclusiveGroup = "shaman_air_totem",
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_InvisibilityTotem",
    },
    optionSchema = { Cat2.CreateSpellRankOption("风之优雅图腾") },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local spellRank = context:GetStepOption(step, "spellRank")

    -- 图腾是否存在
    if not Cat2.AirTotem() then
        Cat2.CastRankedWithNampower("风之优雅图腾", spellRank)
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.AirTotemName() ~= "风之优雅图腾" then
            Cat2.CastRankedWithNampower("风之优雅图腾", spellRank)
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
