-- 8码成串锁敌：新版UnitXP优先选择穿刺成串目标，旧版降级为普通8码外锁敌。
local card = {
    id = "common_auto_target_outside_8",
    name = "自动锁敌（8码成串）",
    description = "适用于|cffABD473猎人|r，选择8码外目标，需UnitXP20260720以上",
    details = "适用于猎人，在8～41码的正面敌人中优先选择穿刺成串目标。死亡目标会被放弃；其他情况下没有合格替代目标时保留当前目标。切换或清除目标后会立即刷新角色数据并继续本轮流程。UnitXP版本不足时降级为扫描并选择最近的合格目标；无SuperWoW时无法自动锁敌。",
    exclusiveGroup = "common_auto_target",
    sort = 22,
    category = "common",
    icons = {
        "Interface\\Icons\\Ability_Hunter_SniperShot",
    },
}

local EXECUTION_INTERVAL = 0.2
local nextExecutionTime = 0
local allowUse = 0
local versionWarningShown = false

local function RefreshPlayerDataAfterTargetChange()
    if Cat2.RefreshPlayerTemporaryInformation then
        Cat2.RefreshPlayerTemporaryInformation()
    end
end

local function IsValidEnemy(unit, context)
    return UnitCanAttack("player", unit)
        and not UnitIsDeadOrGhost(unit)
        and Cat2.IsAutoTargetCandidateAllowed(unit, context)
        and UnitCreatureType(unit) ~= "小动物"
end

local function GetValidEnemyDistance(unit, context)
    if not IsValidEnemy(unit, context) then
        return nil
    end
    local dist = UnitXP("distanceBetween", "player", unit)
    if not dist or dist <= 8 or dist >= 41 then
        return nil
    end
    if UnitXP("behind", unit, "player") or not UnitXP("inSight", "player", unit) then
        return nil
    end
    return dist
end

local function FindNearestFallbackTarget(list, context)
    local nearestDistance = nil
    local nearestTarget = nil
    for key, value in pairs(list) do
        local dist = GetValidEnemyDistance(key, context)
        if dist and (not nearestDistance or dist < nearestDistance) then
            nearestDistance = dist
            nearestTarget = key
        end
    end
    return nearestTarget
end

function card.RefreshRuntimeData()
    allowUse = 0
    if Cat2.UnitXP then
        local succeeded, compileTime = pcall(UnitXP, "version", "coffTimeDateStamp")
        if succeeded and type(compileTime) == "number" and compileTime >= 1784505600 then
            allowUse = 1
        end
    end
end

function card.Execute(context)
    local currentTime = GetTime()
    if currentTime < nextExecutionTime then
        return false
    end
    nextExecutionTime = currentTime + EXECUTION_INTERVAL

    local player = Cat2.PlayerInformation.temporary
    if not Cat2.UnitXP or not Cat2.SuperWoW then
        if player.targetExists and UnitIsDeadOrGhost("target") then
            ClearTarget()
            RefreshPlayerDataAfterTargetChange()
        end
        return false
    end

    if allowUse == 0 and not versionWarningShown then
        DEFAULT_CHAT_FRAME:AddMessage(Cat2.L("|cffff8000当前UnitXP版本不支持成串锁敌，已降级为普通8码外锁敌。|r"))
        versionWarningShown = true
    end

    if player.targetExists and GetValidEnemyDistance("target", context) then
        return false
    end

    local count, _, list = Cat2.ScanNearbyEnemies(41)
    local target = nil

    if allowUse == 1 then
        local guid = UnitXP("farthestInFOV", 2.0, 41)
        -- 底层接口没有8码下限和遮挡检查，返回后必须再次验证。
        if guid and GetValidEnemyDistance(guid, context) then
            target = guid
        end
    end

    -- 旧版UnitXP，或新版接口返回8码内/被遮挡目标时，降级选择最近的合格目标。
    if not target and count > 0 then
        target = FindNearestFallbackTarget(list, context)
    end

    -- 切换前再次检查，避免选中扫描完成后刚死亡的候选单位。
    if target and not UnitIsDeadOrGhost(target) then
        local oldTargetExists, oldTargetGUID = UnitExists("target")
        TargetUnit(target)
        local newTargetExists, newTargetGUID = UnitExists("target")
        if newTargetExists and newTargetGUID ~= oldTargetGUID and GetValidEnemyDistance("target", context) then
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

    if player.targetExists then
        if UnitIsDeadOrGhost("target") then
            ClearTarget()
            RefreshPlayerDataAfterTargetChange()
        end
        -- 活着但不合格的目标继续保留，并允许后续卡片执行。
        return false
    end

    return false
end

Cat2.RegisterCard(card)
