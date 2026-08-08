-- 强击光环 技能卡片。
local card = {
    id = "hunter_trueshot_aura",
    name = "强击光环",
    description = "开启并保持强击光环",
    details = "开启并保持强击光环。",
    sort = 15,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_TrueShot",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    if not Cat2.PlayerInformation.temporary.buff["强击光环"] then
        CastSpellByName("强击光环")
    end

end

Cat2.RegisterCard(card)
