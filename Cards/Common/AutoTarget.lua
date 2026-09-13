-- 自动锁敌（近战）：SuperWoW可用时选择最近的正面近处敌人，否则降级使用原生锁敌。
local card = {
    id = "common_auto_target",
    name = "自动锁敌（近战）",
    description = "选择近处敌对目标，且敌人在你正面。",
    details = "选择最近的近处敌对目标，并检查正面与视野。死亡目标会被放弃；其他情况下没有合格替代目标时保留当前目标。切换或清除目标后会立即刷新角色数据并继续本轮流程。无SuperWoW时降级为原生最近目标：不保证近战距离、正面、视野及小动物过滤。",
    exclusiveGroup = "common_auto_target",
    sort = 20,
    category = "common",
    icons = {
        "Interface\\Icons\\Ability_Hunter_SniperShot",
    },
}

local EXECUTION_INTERVAL = 0.1
local nextExecutionTime = 0

-- 自动锁敌公共逻辑：近战与远程共用执行流程，距离和节流由卡片传入与管理。
-- 自动锁敌各分支共享的战斗状态门禁，由被动卡片控制。
function Cat2.IsAutoTargetCandidateAllowed(unit, context)
    return not context.parameters.autoTargetIgnoreOutOfCombat
        or UnitAffectingCombat(unit)
end

do
    local function IsBasicValidEnemy(unit, context)
        return UnitExists(unit)
            and UnitCanAttack("player", unit)
            and not UnitIsDeadOrGhost(unit)
            and Cat2.IsAutoTargetCandidateAllowed(unit, context)
    end

    local function GetValidNearbyEnemyDistance(unit, maximumDistance, context)
        if not IsBasicValidEnemy(unit, context) or UnitCreatureType(unit) == "小动物" then
            return nil
        end
        if UnitXP("behind", unit, "player") or not UnitXP("inSight", "player", unit) then
            return nil
        end
        local dist = UnitXP("distanceBetween", "player", unit)
        if not dist or dist >= maximumDistance then
            return nil
        end
        return dist
    end

    -- 对象表可能尚未记录刚进入视野的敌人；用UnitXP直接扫描可见对象补充一次。
    -- 接口本身没有卡片设定的距离上限，若结果不合格则恢复原目标，避免无候选时误切。
    local function TryTargetNearestUnitXPEnemy(maximumDistance, context)
        local oldTargetExists, oldTargetGUID = UnitExists("target")
        local succeeded, selected = pcall(UnitXP, "target", "nearestEnemy")
        -- 接口即使返回失败，也可能已经改变目标；由外层统一刷新最终状态。
        if not succeeded or not selected then
            return false
        end

        local newTargetExists, newTargetGUID = UnitExists("target")
        if newTargetExists and newTargetGUID ~= oldTargetGUID and GetValidNearbyEnemyDistance("target", maximumDistance, context) then
            return newTargetGUID
        end

        if oldTargetExists and oldTargetGUID then
            TargetUnit(oldTargetGUID)
        elseif newTargetExists then
            ClearTarget()
        end
        return false
    end

    -- 选择设定距离内最近的合格敌人；返回是否尝试过目标操作。
    local function ExecuteTargetSelection(context, maximumDistance)
        local needsRefresh = false

        if Cat2.UnitXP and Cat2.SuperWoW then
            if UnitExists("target") and GetValidNearbyEnemyDistance("target", maximumDistance, context) then
                return needsRefresh
            end

            local count, _, list = Cat2.ScanNearbyEnemies(maximumDistance)
            local nearestDistance = nil
            local nearestTarget = nil
            if count > 0 then
                for key, value in pairs(list) do
                    local dist = GetValidNearbyEnemyDistance(key, maximumDistance, context)
                    if dist and (not nearestDistance or dist < nearestDistance) then
                        nearestDistance = dist
                        nearestTarget = key
                    end
                end
            end

            -- 切换前再次检查，缩小候选单位在扫描后死亡造成的竞态窗口。
            if nearestTarget and not UnitIsDeadOrGhost(nearestTarget) then
                local oldTargetExists, oldTargetGUID = UnitExists("target")
                TargetUnit(nearestTarget)
                needsRefresh = true
                local newTargetExists, newTargetGUID = UnitExists("target")
                if newTargetExists and newTargetGUID ~= oldTargetGUID and GetValidNearbyEnemyDistance("target", maximumDistance, context) then
                    return needsRefresh
                end
                -- TargetUnit可能因候选失效而静默失败；未确认切换时恢复原目标。
                if oldTargetExists and oldTargetGUID then
                    TargetUnit(oldTargetGUID)
                    needsRefresh = true
                elseif newTargetExists then
                    ClearTarget()
                    needsRefresh = true
                end
            end

            needsRefresh = true -- 补扫也会尝试切换目标。
            if TryTargetNearestUnitXPEnemy(maximumDistance, context) then
                return needsRefresh
            end

            if UnitExists("target") then
                if UnitIsDeadOrGhost("target") then
                    ClearTarget()
                    needsRefresh = true
                end
                -- 活着但不合格且没有替代目标时继续保留，并允许后续卡片执行。
                return needsRefresh
            end

            -- UnitXP补扫不可用时降级为原生锁敌；不合格结果立即清除。
            TargetNearestEnemy()
            needsRefresh = true
            if UnitExists("target") and not GetValidNearbyEnemyDistance("target", maximumDistance, context) then
                ClearTarget()
                needsRefresh = true
            end
            return needsRefresh
        end

        -- 无SuperWoW时只能依赖原生最近目标；有效旧目标不主动改选。
        if IsBasicValidEnemy("target", context) then
            return needsRefresh
        end
        if UnitExists("target") then
            if UnitIsDeadOrGhost("target") then
                ClearTarget()
                needsRefresh = true
                TargetNearestEnemy()
                needsRefresh = true
                if UnitExists("target") and not IsBasicValidEnemy("target", context) then
                    ClearTarget()
                    needsRefresh = true
                end
            end
            return needsRefresh
        end
        TargetNearestEnemy()
        needsRefresh = true
        if UnitExists("target") and not IsBasicValidEnemy("target", context) then
            ClearTarget()
            needsRefresh = true
        end
        return needsRefresh
    end
    -- 中途校验使用实时状态；选敌完成后至多刷新一次，供后续卡片读取。
    function Cat2.ExecuteAutoTarget(context, maximumDistance)
        if ExecuteTargetSelection(context, maximumDistance) and Cat2.RefreshPlayerTemporaryInformation then
            Cat2.RefreshPlayerTemporaryInformation()
        end
        return false
    end
end

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local currentTime = GetTime()
    if currentTime < nextExecutionTime then
        return false
    end
    nextExecutionTime = currentTime + EXECUTION_INTERVAL

    return Cat2.ExecuteAutoTarget(context, 6)
end

Cat2.RegisterCard(card)
