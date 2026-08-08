-- 豹群守护技能卡片。
local card = {
    id = "hunter_aspect_of_the_pack",
    name = "豹群守护",
    description = "切换并保持豹群守护",
    details = "切换并保持豹群守护。",
    sort = 14,
    category = "class",
    exclusiveGroup = "hunter_aspect",
    classes = {
        HUNTER = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Mount_WhiteTiger",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    if not Cat2.PlayerInformation.temporary.buff["豹群守护"] then
        CastSpellByName("豹群守护")
    end
end

Cat2.RegisterCard(card)
