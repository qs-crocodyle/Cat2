-- 爆炸陷阱 技能卡片。
local card = {
    id = "hunter_explosive_trap",
    name = "爆炸陷阱",
    description = "目标战斗中且在近战距离时，施放爆炸陷阱，需SuperWoW",
    details = "目标处于战斗中且在近战距离时，施放爆炸陷阱，需SuperWoW。仅在技能可用时尝试执行。",
    sort = 80,
    exclusiveGroup = "hunter_trap",
    category = "class",
    classes = {
        HUNTER = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_SelfDestruct",
    },
    cooldown = {
        type = "spell",
        name = "爆炸陷阱",
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

    -- 目标尚未进入战斗时不提前放置陷阱。
    if not player.targetInCombat then
        return false
    end


    -- 8码内
    if Cat2.TargetDistance() then
        if Cat2.SpellReady("爆炸陷阱") then
            Cat2.Cast("爆炸陷阱")
            return true
        end
    end

    return false

end

Cat2.RegisterCard(card)
