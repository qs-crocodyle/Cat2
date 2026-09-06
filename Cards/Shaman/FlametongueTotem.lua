-- 火舌图腾 技能卡片。
local card = {
    id = "shaman_flametongue_totem",
    name = "火舌图腾",
    description = "保持并施放|cff6bc7e0{spellRank}级|r火舌图腾",
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
    optionSchema = { Cat2.CreateSpellRankOption("火舌图腾") },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local spellRank = context:GetStepOption(step, "spellRank")

    -- 图腾是否存在
    if not Cat2.FireTotem() then
        Cat2.CastRankedWithNampower("火舌图腾", spellRank)
        return false
    end

    local Force = context and context.parameters and context.parameters.TotemForceOverride
    if Force then
        -- 图腾名字比对
        if Cat2.FireTotemName() ~= "火舌图腾" then
            Cat2.CastRankedWithNampower("火舌图腾", spellRank)
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
