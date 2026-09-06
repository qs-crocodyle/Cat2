-- 地缚图腾 技能卡片。
local card = {
    id = "shaman_earthbind_totem",
    name = "地缚图腾",
    description = "保持并施放|cff6bc7e0{spellRank}级|r地缚图腾",
    details = "保持并施放地缚图腾。",
    sort = 50,
    exclusiveGroup = "shaman_earth_totem",
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_StrengthOfEarthTotem02",
    },
    optionSchema = { Cat2.CreateSpellRankOption("地缚图腾") },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local spellRank = context:GetStepOption(step, "spellRank")

    -- 图腾是否存在
    if not Cat2.EarthTotem() then
        Cat2.CastRankedWithNampower("地缚图腾", spellRank)
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.EarthTotemName() ~= "地缚图腾" then
            Cat2.CastRankedWithNampower("地缚图腾", spellRank)
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
