-- 自动陷阱技能卡片。
-- 复用爆炸陷阱的施放条件与执行逻辑；与其他猎人陷阱同属互斥小组。
local card = {
    id = "hunter_auto_trap",
    name = "自动陷阱",
    description = "目标战斗中，根据附近敌人数自动选择陷阱，需SuperWoW",
    details = "目标处于战斗中且附近存在敌人时，根据敌人数量选择陷阱：至少2个敌人使用爆炸陷阱，1个敌人使用献祭陷阱。需SuperWoW。",
    sort = 70,
    exclusiveGroup = "hunter_trap",
    category = "class",
    classes = {
        HUNTER = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_SelfDestruct",
        "Interface\\Icons\\Spell_Fire_FlameShock",
    },
    cooldown = {
        type = "spell",
        name = "献祭陷阱",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标就无需继续。
    if not player.targetExists then
        return false
    end

    -- 目标尚未进入战斗时不提前放置陷阱。
    if not player.targetInCombat then
        return false
    end

    local nearby = Cat2.ScanNearbyEnemies(6)

    if nearby >= 2 then

        if Cat2.SpellReady("爆炸陷阱") then
            Cat2.Cast("爆炸陷阱")
            return true
        end

    elseif nearby == 1 then

        if Cat2.SpellReady("献祭陷阱") then
            Cat2.Cast("献祭陷阱")
            return true
        end

    end

    return false
end

Cat2.RegisterCard(card)
