-- 野兽守护技能卡片。
local card = {
    id = "hunter_aspect_of_the_beast",
    name = "野兽守护",
    description = "切换并保持野兽守护",
    details = "切换并保持野兽守护。",
    sort = 17,
    category = "class",
    exclusiveGroup = "hunter_aspect",
    classes = {
        HUNTER = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Mount_PinkTiger",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    if not Cat2.PlayerInformation.temporary.buff["野兽守护"] then
        CastSpellByName("野兽守护")
    end
end

Cat2.RegisterCard(card)
