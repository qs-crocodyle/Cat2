-- 灵猴守护技能卡片。
local card = {
    id = "hunter_aspect_of_the_monkey",
    name = "灵猴守护",
    description = "切换并保持灵猴守护",
    details = "切换并保持灵猴守护。",
    sort = 16,
    category = "class",
    exclusiveGroup = "hunter_aspect",
    classes = {
        HUNTER = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Hunter_AspectOfTheMonkey",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    if not Cat2.PlayerInformation.temporary.buff["灵猴守护"] then
        CastSpellByName("灵猴守护")
    end
end

Cat2.RegisterCard(card)
