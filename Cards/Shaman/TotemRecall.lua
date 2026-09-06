-- 图腾召回 技能卡片；具体执行逻辑留给后续实现。
local card = {
    id = "shaman_totem_recall",
    name = "图腾召回",
    description = "距离图腾超过|cff6bc7e0{recallDistance}码|r时召回，需UnitXP模组",
    details = "当你离开图腾距离超过设定值，自动施放图腾召回，此机制在任意一个图腾超出都会进行召回。",
    sort = 0,
    category = "class",
    classes = {
        SHAMAN = 4,
    },
    icons = {
        "Interface\\Icons\\Spell_Shaman_TotemRecall",
    },
    optionSchema = {
        {
            key = "recallDistance",
            type = "number",
            label = "召回距离",
            shortLabel = "距",
            unit = "码",
            default = 30,
            minimum = 1,
            maximum = 100,
        },
    },
    cooldown = { type = "spell", name = "图腾召回" },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local recallDistance = context:GetStepOption(step, "recallDistance") or 30

    if not Cat2.SpellReady("图腾召回") then
        return false
    end

    if Cat2.EarthTotemOutside() > recallDistance
        or Cat2.FireTotemOutside() > recallDistance
        or Cat2.WaterTotemOutside() > recallDistance
        or Cat2.AirTotemOutside() > recallDistance then
        Cat2.Cast("图腾召回")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
