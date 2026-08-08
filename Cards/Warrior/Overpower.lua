-- 压制 技能卡片。
local card = {
    id = "warrior_overpower",
    name = "压制",
    description = "怒气<30，切战斗姿态，施放压制",
    details = "怒气<30，切战斗姿态，施放压制。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 40,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_MeleeDamage",
        "Interface\\Icons\\Ability_Warrior_OffensiveStance",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    -- 压制触发，CD满足
    if Cat2.WarriorOverpower() and Cat2.SpellReadyOffset("压制",1.5) then

        if Cat2.SetShape("战斗姿态") then
            CastSpellByName("压制")
            return true
        end

        if player.power<90 and not Cat2.SetShape("战斗姿态") then
            CastSpellByName("战斗姿态")
            return true
        end

    end

    return false
end

Cat2.RegisterCard(card)