-- 猎豹守护技能卡片。
local card = {
    id = "hunter_aspect_of_the_cheetah",
    name = "猎豹守护",
    description = "切换并保持猎豹守护",
    details = "切换并保持猎豹守护。",
    sort = 13,
    category = "class",
    exclusiveGroup = "hunter_aspect",
    classes = {
        HUNTER = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Mount_JungleTiger",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    if not Cat2.PlayerInformation.temporary.buff["猎豹守护"] then
        CastSpellByName("猎豹守护")
    end
end

Cat2.RegisterCard(card)
