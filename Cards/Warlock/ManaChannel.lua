-- 法力通道技能卡片。
local card = {
    id = "warlock_mana_channel",
    name = "法力通道",
    description = "施放法力通道",
    details = "施放法力通道。成功执行时会阻断本轮后续卡片。",
    sort = 35,
    exclusiveGroup = "warlock_demon_channel",
    category = "class",
    classes = {
        WARLOCK = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_SiphonMana",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not UnitExists("pet") then
        return false
    end

    Cat2.CastWithoutNampower("法力通道")
    return true

end

Cat2.RegisterCard(card)
