-- 斩杀 周围可斩目标卡片。
-- 目前完整继承“斩杀（高怒）”的安全执行条件；后续若要加入周围目标扫描，
-- 应在确认目标切换规则后单独扩展，不能在此猜测施法目标。
local card = {
    id = "warrior_execute_nearby_target",
    name = "斩杀 周围可斩目标",
    description = "周围目标血量满足斩杀时，尝试对其施放斩杀",
    details = "周围目标血量满足斩杀时，尝试对其施放斩杀。仅对可攻击目标生效。会检查当前资源和相关生命值。启用“斩杀时中断读条”后，施放前会中断猛击读条。",
    sort = 98,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\INV_Sword_48",
    },
}

local powerExecute = 15

function card.RefreshRuntimeData()
    powerExecute = 15

    if Cat2.IsTalentLearned(2, 13) == 1 then
        powerExecute = powerExecute - 2
    elseif Cat2.IsTalentLearned(2, 13) == 2 then
        powerExecute = powerExecute - 5
    end
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    local count,_,list = Cat2.ScanNearbyEnemies()
    if count>0 then

        -- 有近战敌人

        for key, value in pairs(list) do

            if UnitExists(key) then

                local health = UnitHealth(key)
                local maxHealth = UnitHealthMax(key)

                if health>0 and maxHealth>0 and UnitCanAttack("player", key) then

                    local percent = health/maxHealth * 100

                    -- 尝试斩杀
                    if player.power>=powerExecute and percent<19.9 then
                        if context.parameters.warriorInterruptCastForExecute then
                            if Cat2.GetIsCast() then
                                SpellStopCasting()
                            end
                        end
                        Cat2.CastSpellWithoutTarget("斩杀", key)
                    end

                end

            end

        end
    end

    return false
end

Cat2.RegisterCard(card)
