-- 猎神加农炮：aim 最远目标选怪，仅荷枪实弹触发。
local card = {
    id = "hunter_cannon",
    name = "猎神加农炮 |cff00ff00-楚人美心善提供|r",
    description = "对最远目标无痕荷枪实弹瞄准",
    details = "在41码范围内寻找距离玩家最远的敌对目标，发现后直接无痕施放瞄准射击。需要SuperWoW+UnitXP 模组。成功执行时会阻断本轮后续卡片。",
    sort = 45.3,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\INV_Spear_07",
    },
    cooldown = {
        type = "spell",
        name = "瞄准射击",
    },
}

local allowUse = 0
local minimumDistance = 8
local maximumDistance = 41

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(2, 6)
    if Cat2.UnitXP then
        local minVal, maxVal = Cat2.Match(Cat2.GetSpellTooltip("瞄准射击", "等级 1"), "(%d+)%s*%-%s*(%d+)码距离")
        minimumDistance = tonumber(minVal) or 8
        maximumDistance = tonumber(maxVal) or 41
    end
end

-- 检查目标是否有效（当前目标参与候选池）
local function IsValidTarget(targetGuid)
    if not UnitCanAttack("player", targetGuid) then
        return false
    end
    if UnitIsDeadOrGhost(targetGuid) then
        return false
    end
    local creatureType = UnitCreatureType(targetGuid)
    if creatureType == "小动物" or creatureType == "Critter" then
        return false
    end
    if not UnitAffectingCombat(targetGuid) then
        return false
    end
    return true
end

-- 检查目标距离和朝向
local function IsValidPosition(targetGuid)
    local dist = UnitXP("distanceBetween", "player", targetGuid)
    if not dist or dist < minimumDistance or dist > maximumDistance then
        return false
    end
    if UnitXP("behind", targetGuid, "player") then
        return false
    end
    if not UnitXP("inSight", "player", targetGuid) then
        return false
    end
    return true
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    -- 无目标或无荷枪实弹 buff，跳过
    if not player.targetExists or not player.buff["荷枪实弹"] then
        return false
    end
    if allowUse == 0 then return false end
    if not Cat2.SpellReady("瞄准射击") then return false end
    if not Cat2.SuperWoW or not Cat2.UnitXP then return false end

    -- 获取当前目标的 guid
    local currentGuid = player.targetGUID

    -- 扫描41码范围内所有敌人
    local count, _, list = Cat2.ScanNearbyEnemies(41)
    if count == 0 then return false end

    -- aim1 最远目标选怪：找41码内最远的符合要求的敌对目标
    local bestTarget = nil
    local bestDist = 0

    for key, _ in pairs(list) do
        local targetGuid = key
        -- 检查目标是否有效
        if IsValidTarget(targetGuid) then
            if IsValidPosition(targetGuid) then
                local dist = UnitXP("distanceBetween", "player", targetGuid)
                -- 选最远的
                if dist > bestDist then
                    bestDist = dist
                    bestTarget = targetGuid
                end
            end
        end
    end

    if not bestTarget then return false end

    -- 对目标 guid 直接施放瞄准射击（不切换当前目标）
    Cat2.Cast("瞄准射击", bestTarget)
    return true
end

Cat2.RegisterCard(card)
