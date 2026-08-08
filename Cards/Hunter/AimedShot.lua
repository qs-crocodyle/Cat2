-- 瞄准射击 技能卡片。
local card = {
    id = "hunter_aimed_shot",
    name = "瞄准射击",
    description = "降低占用自动射击，荷枪实弹影响瞄准射击的时机",
    details = "降低占用自动射击，荷枪实弹影响瞄准射击的时机。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 45,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\INV_Spear_07",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(2,6)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    -- 技能未准备好
    if not Cat2.SpellReady("瞄准射击") then
        return false
    end

    local range_speed = UnitRangedDamage("player") / 2

    if player.buff["荷枪实弹"] then
        range_speed = range_speed - 1.0
    end

    if player.buff["急速射击"] then
        range_speed = range_speed - 0.5
    end

    if Cat2.GetHunterShotLeft()>range_speed then
        CastSpellByName("瞄准射击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
