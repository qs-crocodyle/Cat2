-- 暗影箭 技能卡片。
local card = {
    id = "warlock_shadow_bolt",
    name = "暗影箭",
    description = "施放暗影箭，适合做填充技能",
    details = "施放暗影箭，适合做填充技能。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 10,
    category = "class",
    classes = {
        WARLOCK = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_ShadowBolt",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    Cat2.CastWithoutNampower("暗影箭")
    return true
end

Cat2.RegisterCard(card)