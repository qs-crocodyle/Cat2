-- 生命通道 技能卡片。
local card = {
    id = "warlock_health_funnel",
    name = "生命通道",
    description = "施放生命通道",
    details = "施放生命通道。成功执行时会阻断本轮后续卡片。",
    sort = 30,
    exclusiveGroup = "warlock_demon_channel",
    category = "class",
    classes = {
        WARLOCK = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_LifeDrain",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not UnitExists("pet") then
        return false
    end

    Cat2.CastWithoutNampower("生命通道")
    return true

end

Cat2.RegisterCard(card)
