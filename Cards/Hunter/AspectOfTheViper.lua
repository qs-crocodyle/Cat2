-- 蝰蛇守护技能卡片。
local card = {
    id = "hunter_aspect_of_the_viper",
    name = "蝰蛇守护",
    description = "切换并保持蝰蛇守护",
    details = "切换并保持蝰蛇守护。",
    sort = 11,
    category = "class",
    exclusiveGroup = "hunter_aspect",
    classes = {
        HUNTER = 1,
    },
    icons = {
        "Interface\\Icons\\ability_hunter_aspectoftheviper",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not Cat2.PlayerInformation.temporary.buff["蝰蛇守护"] then
        CastSpellByName("蝰蛇守护")
    end

end

Cat2.RegisterCard(card)
