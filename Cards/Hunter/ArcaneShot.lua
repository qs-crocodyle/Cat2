-- 奥术射击 技能卡片。
local card = {
    id = "hunter_arcane_shot",
    name = "奥术射击",
    description = "施放奥术射击",
    details = "施放奥术射击。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 40,
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


    if Cat2.SpellReady("奥术射击") then
        CastSpellByName("奥术射击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
