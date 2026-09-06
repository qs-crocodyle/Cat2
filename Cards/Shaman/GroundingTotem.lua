-- 根基图腾 技能卡片。
local card = {
    id = "shaman_grounding_totem",
    name = "根基图腾",
    description = "保持并施放|cff6bc7e0{spellRank}级|r根基图腾",
    details = "保持并施放根基图腾。",
    sort = 160,
    exclusiveGroup = "shaman_air_totem",
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_GroundingTotem",
    },
    optionSchema = { Cat2.CreateSpellRankOption("根基图腾") },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local spellRank = context:GetStepOption(step, "spellRank")

    -- 图腾是否存在
    if not Cat2.AirTotem() then
        Cat2.CastRankedWithNampower("根基图腾", spellRank)
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.AirTotemName() ~= "根基图腾" then
            Cat2.CastRankedWithNampower("根基图腾", spellRank)
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
