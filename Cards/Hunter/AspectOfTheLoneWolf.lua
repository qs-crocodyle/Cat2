-- 孤狼守护技能卡片。
local card = {
    id = "hunter_aspect_of_the_lone_wolf",
    name = "孤狼守护",
    description = "切换并保持孤狼守护",
    details = "切换并保持孤狼守护。",
    sort = 12,
    category = "class",
    exclusiveGroup = "hunter_aspect",
    classes = {
        HUNTER = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Mount_WhiteDireWolf",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not Cat2.PlayerInformation.temporary.buff["孤狼守护"] then
        CastSpellByName("孤狼守护")
    end

end

Cat2.RegisterCard(card)
