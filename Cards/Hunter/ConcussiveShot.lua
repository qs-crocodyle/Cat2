-- 震荡射击 技能卡片。
local card = {
    id = "hunter_concussive_shot",
    name = "震荡射击",
    description = "施放震荡射击",
    details = "施放震荡射击。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 56,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_Stun",
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


    if Cat2.SpellReady("震荡射击") then
        CastSpellByName("震荡射击")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
