-- 奥术射击（魔力弹药）技能卡片。
local card = {
    id = "hunter_arcane_shot_magic_ammo",
    name = "奥术射击（魔力弹药）",
    description = "触发魔力弹药时，施放奥术射击",
    details = "触发魔力弹药时，施放奥术射击。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 55.7,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_ImpalingBolt",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end


    if player.buff["魔力弹药"] and Cat2.SpellReady("奥术射击") then
        CastSpellByName("奥术射击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
