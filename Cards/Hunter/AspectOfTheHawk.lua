-- 雄鹰守护 技能卡片。
local card = {
    id = "hunter_aspect_of_the_hawk",
    name = "雄鹰守护",
    description = "切换并保持雄鹰守护",
    details = "切换并保持雄鹰守护。",
    sort = 10,
    category = "class",
    exclusiveGroup = "hunter_aspect",
    classes = {
        HUNTER = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_RavenForm",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not Cat2.PlayerInformation.temporary.buff["雄鹰守护"] then
        CastSpellByName("雄鹰守护")
    end

end

Cat2.RegisterCard(card)
