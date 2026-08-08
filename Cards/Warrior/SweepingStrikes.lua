-- 横扫攻击 技能卡片。
local card = {
    id = "warrior_sweeping_strikes",
    name = "横扫攻击",
    description = "周围多敌人时自动开启横扫，需SuperWoW",
    details = "周围多敌人时自动开启横扫，需SuperWoW。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 90,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_SliceDice",
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

    local nearby = Cat2.ScanNearbyEnemies(8)

	if Cat2.SpellReady("横扫攻击") and nearby>1 and player.power>=20 then

        if Cat2.SetShape("战斗姿态") then
            CastSpellByName("横扫攻击")
            return true
        else
            CastSpellByName("战斗姿态")
            return true
        end

	end

    return false
end

Cat2.RegisterCard(card)