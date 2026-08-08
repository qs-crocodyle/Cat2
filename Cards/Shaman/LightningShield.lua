-- 闪电之盾 技能卡片。
local card = {
    id = "shaman_lightning_shield",
    name = "闪电之盾",
    description = "施放闪电之盾，同时只能持续一个盾",
    details = "施放闪电之盾，同时只能持续一个盾。",
    sort = 50,
    exclusiveGroup = "shaman_shield",
    category = "class",
    classes = {
        SHAMAN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_LightningShield",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.buff["闪电之盾"] then
        CastSpellByName("闪电之盾")
        return
    end

    return false

end

Cat2.RegisterCard(card)
