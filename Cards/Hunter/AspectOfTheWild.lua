-- 野性守护技能卡片。
local card = {
    id = "hunter_aspect_of_the_wild",
    name = "野性守护",
    description = "切换并保持野性守护",
    details = "切换并保持野性守护。",
    sort = 15,
    category = "class",
    exclusiveGroup = "hunter_aspect",
    classes = {
        HUNTER = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_ProtectionformNature",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    if not Cat2.PlayerInformation.temporary.buff["野性守护"] then
        CastSpellByName("野性守护")
    end
end

Cat2.RegisterCard(card)
