-- 狂暴技能卡片：沿用盗贼“冲动”的低能量触发机制。
local card = {
    id = "druid_berserk",
    name = "狂暴",
    description = "技能冷却后，能量低于40时施放狂暴",
    details = "技能冷却后，能量低于40时施放狂暴。需要存在有效目标。会检查目标距离。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 423.1,
    category = "class",
    classes = {
        DRUID = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Druid_Berserk",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(2,15)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    if player.power < 40 and Cat2.SpellReady("狂暴") and Cat2.TargetDistance() then
        CastSpellByName("狂暴")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
