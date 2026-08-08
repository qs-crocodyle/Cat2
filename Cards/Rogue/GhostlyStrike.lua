-- 鬼魅攻击 技能卡片。
local card = {
    id = "rogue_ghostly_strike",
    name = "鬼魅攻击",
    description = "冷却好后，施展鬼魅攻击",
    details = "冷却好后，施展鬼魅攻击。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 120,
    category = "class",
    classes = {
        ROGUE = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_Curse",
    },
}

local ghostPower = 40

function card.RefreshRuntimeData()

    ghostPower = 40

    local count = Cat2.IsTalentLearned(3,17)
    if count==1 then
        ghostPower = ghostPower - 3
    elseif count==2 then
        ghostPower = ghostPower - 6
    elseif count==3 then
        ghostPower = ghostPower - 10
    end

end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    if player.power>=ghostPower and Cat2.SpellReady("鬼魅攻击") then
        CastSpellByName("鬼魅攻击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)