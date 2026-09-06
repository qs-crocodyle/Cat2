-- 自动锁敌（远程）：复制近战锁敌逻辑，保留独立卡片标识与运行节流状态。
local card = {
    id = "common_auto_target_ranged",
    name = "自动锁敌（远程）",
    description = "选择|cff6bc7e0{maximumDistance}码|r内最近的正面敌对目标。",
    details = "选择设定距离内最近的敌对目标，并检查正面与视野；默认最大距离为41码。死亡目标会被放弃；其他情况下没有合格替代目标时保留当前目标。切换或清除目标后会立即刷新角色数据并继续本轮流程。无SuperWoW时降级为原生最近目标：不保证距离、正面、视野及小动物过滤。",
    exclusiveGroup = "common_auto_target",
    sort = 21,
    category = "common",
    icons = {
        "Interface\\Icons\\Ability_Hunter_SniperShot",
    },
    optionSchema = {
        {
            key = "maximumDistance",
            type = "number",
            label = "锁敌距离",
            unit = "码",
            default = 36,
            minimum = 1,
            maximum = 100,
        },
    },
}

local EXECUTION_INTERVAL = 0.1
local nextExecutionTime = 0

local function RefreshPlayerDataAfterTargetChange()
    if Cat2.RefreshPlayerTemporaryInformation then
        Cat2.RefreshPlayerTemporaryInformation()
    end
end

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

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local currentTime = GetTime()
    if currentTime < nextExecutionTime then
        return false
    end
    nextExecutionTime = currentTime + EXECUTION_INTERVAL

    local player = Cat2.PlayerInformation.temporary
    local maximumDistance = context:GetStepOption(step, "maximumDistance") or 41

    if Cat2.UnitXP and Cat2.SuperWoW then
        if player.targetExists and GetValidNearbyEnemyDistance("target", maximumDistance, context) then
            return false
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
            local newTargetExists, newTargetGUID = UnitExists("target")
            if newTargetExists and newTargetGUID ~= oldTargetGUID and GetValidNearbyEnemyDistance("target", maximumDistance, context) then
                RefreshPlayerDataAfterTargetChange()
                return false
            end
            -- TargetUnit可能因候选失效而静默失败；未确认切换时恢复原目标。
            if oldTargetExists and oldTargetGUID then
                TargetUnit(oldTargetGUID)
            elseif newTargetExists then
                ClearTarget()
            end
        end

        if TryTargetNearestUnitXPEnemy(maximumDistance, context) then
            RefreshPlayerDataAfterTargetChange()
            return false
        end

        if player.targetExists then
            if UnitIsDeadOrGhost("target") then
                ClearTarget()
                RefreshPlayerDataAfterTargetChange()
            end
            -- 活着但不合格且没有替代目标时继续保留，并允许后续卡片执行。
            return false
        end

        -- UnitXP补扫不可用时降级为原生锁敌；不合格结果立即清除。
        TargetNearestEnemy()
        if UnitExists("target") and not GetValidNearbyEnemyDistance("target", maximumDistance, context) then
            ClearTarget()
        end
        RefreshPlayerDataAfterTargetChange()
        return false
    end

    -- 无SuperWoW时只能依赖原生最近目标；有效旧目标不主动改选。
    if IsBasicValidEnemy("target", context) then
        return false
    end
    if player.targetExists then
        if UnitIsDeadOrGhost("target") then
            ClearTarget()
            TargetNearestEnemy()
            if UnitExists("target") and not IsBasicValidEnemy("target", context) then
                ClearTarget()
            end
            RefreshPlayerDataAfterTargetChange()
        end
        return false
    end
    TargetNearestEnemy()
    if UnitExists("target") and not IsBasicValidEnemy("target", context) then
        ClearTarget()
    end
    RefreshPlayerDataAfterTargetChange()
    return false
end

Cat2.RegisterCard(card)
