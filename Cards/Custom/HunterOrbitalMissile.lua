-- 猎神智轨加农炮：aim2 窄角精准穿透选怪，仅荷枪实弹触发。
local card = {
    id = "hunter_orbital_missile",
    name = "猎神智轨加农炮 |cff00ff00-楚人美心善提供|r",
    description = "对可以穿刺最多的最远怪进行无痕荷枪实弹瞄准",
    details = "精确计算出瞄准射击最大穿刺数量，保持选定目标不变，对着这条直线无痕荷枪实弹瞄准，需要SuperWoW+UnitXP 模组（无需最新，香草盒子里的够用）。成功执行时会阻断本轮后续卡片。",
    sort = 45.2,
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
    local targetDist = UnitXP("distanceBetween", "player", targetGuid)
    if not targetDist or targetDist < minimumDistance or targetDist > maximumDistance then
        return false, 0
    end
    if UnitXP("behind", targetGuid, "player") then
        return false, 0
    end
    if not UnitXP("inSight", "player", targetGuid) then
        return false, 0
    end
    if targetDist < 5 then
        return false, 0
    end
    return true, targetDist
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

    -- aim2 穿透选怪：用余弦定理计算每个候选目标的穿透数量
    local bestTarget = nil
    local bestScore = 0
    local pierceWidth = 2
    local cosThreshold = 0.87
    local distMargin = 33

    for key, _ in pairs(list) do
        local targetGuid = key
        -- 检查目标是否有效
        if IsValidTarget(targetGuid) then
            local valid, targetDist = IsValidPosition(targetGuid)
            if valid then
                -- 计算穿透分数
                local score = 0
                for enemyKey, _ in pairs(list) do
                    local enemyGuid = enemyKey
                    if enemyGuid ~= targetGuid then
                        local enemyDist = UnitXP("distanceBetween", "player", enemyGuid)
                        if enemyDist then
                            if enemyDist <= targetDist + distMargin then
                                local betweenDist = UnitXP("distanceBetween", targetGuid, enemyGuid)
                                if betweenDist then
                                    local pa = enemyDist
                                    local pb = targetDist
                                    local ab = betweenDist
                                    if pa > 0 and pb > 0 then
                                        local cosAngle = (pa * pa + pb * pb - ab * ab) / (2 * pa * pb)
                                        if cosAngle > 1 then cosAngle = 1 end
                                        if cosAngle < -1 then cosAngle = -1 end
                                        if cosAngle >= cosThreshold then
                                            local sinAngle = math.sqrt(1 - cosAngle * cosAngle)
                                            local perpDist = pa * sinAngle
                                            if perpDist <= pierceWidth then
                                                score = score + 1
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                -- 评分：穿透数量优先，数量相同选更远的
                local bestDistVal = 0
                if bestTarget then
                    bestDistVal = UnitXP("distanceBetween", "player", bestTarget) or 0
                end
                if score > bestScore or (score == bestScore and targetDist > bestDistVal) then
                    bestScore = score
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
