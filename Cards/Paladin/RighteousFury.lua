-- 正义之怒 技能卡片。
local card = {
    id = "paladin_righteous_fury",
    name = "正义之怒",
    description = "打开并保持正义之怒",
    details = "打开并保持正义之怒。",
    sort = 70,
    category = "class",
    classes = {
        PALADIN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_SealOfFury",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not Cat2.PlayerInformation.temporary.buff["正义之怒"] then
        CastSpellByName("正义之怒")
    end

end

Cat2.RegisterCard(card)