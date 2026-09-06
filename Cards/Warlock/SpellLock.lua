-- 地狱猎犬法术封锁打断卡片。以宠物动作栏中的实际技能为准，避免仅凭宠物名称误判。
local function GetSpellLockPetActionSlot()
    if type(GetPetActionInfo) ~= "function" then
        return nil
    end

    local slot = 1
    while slot <= 10 do
        local actionName, actionSubtext, actionTexture, isToken = GetPetActionInfo(slot)
        if actionName and isToken then
            if type(getglobal) == "function" then
                actionName = getglobal(actionName) or actionName
            elseif type(_G) == "table" then
                actionName = _G[actionName] or actionName
            end
        end
        if actionName == "法术封锁" then
            return slot
        end
        slot = slot + 1
    end

    return nil
end

local function GetSpellLockPetActionCooldown()
    local slot = GetSpellLockPetActionSlot()
    if not slot or type(GetPetActionCooldown) ~= "function" then
        return nil
    end
    return GetPetActionCooldown(slot)
end

local function IsSpellLockPetActionReady(slot)
    if not slot or type(GetPetActionCooldown) ~= "function" then
        return false
    end

    local startTime, duration, enabled = GetPetActionCooldown(slot)
    if enabled == 0 then
        return false
    end

    startTime = tonumber(startTime) or 0
    duration = tonumber(duration) or 0
    return duration <= 0 or GetTime() - startTime >= duration
end

local card = {
    id = "warlock_spell_lock",
    name = "法术封锁",
    description = "目标施放|cff6bc7e0{interruptSpellName}|r时使用法术封锁；技能名为空则打断任意读条",
    details = "目标读条时命令宠物施放法术封锁。打断技能名为空时打断任意捕获到的敌方读条；填写后仅在敌方施法名与设定内容完全相同时施放。需要存活宠物且宠物动作栏中存在法术封锁，因此其他恶魔不会误触发。会检查宠物到目标的距离与宠物技能冷却；玩家自身读条不会被中止。需SuperWoW模组。成功执行时会阻断本轮后续卡片。",
    sort = 999,
    category = "class",
    classes = {
        WARLOCK = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_MindRot",
    },
    cooldown = {
        type = "custom",
        cacheKey = "pet-action:法术封锁",
        GetCooldown = function()
            return GetSpellLockPetActionCooldown()
        end,
    },
    optionSchema = {
        {
            key = "interruptSpellName",
            type = "string",
            label = "打断技能名",
            shortLabel = "技能",
            default = "",
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local interruptSpellName = context:GetStepOption(step, "interruptSpellName") or ""

    if not player.targetExists then
        return false
    end

    if not UnitExists("pet") or UnitIsDeadOrGhost("pet") then
        return false
    end

    local actionSlot = GetSpellLockPetActionSlot()
    if not actionSlot then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "pet", "target")
        if targetDistance and targetDistance > 30 then
            return false
        end
    end

    local cast, name = Cat2.TargetCast()
    if not cast then
        return false
    end
    if interruptSpellName ~= "" and name ~= interruptSpellName then
        return false
    end

    if not IsSpellLockPetActionReady(actionSlot) or type(CastPetAction) ~= "function" then
        return false
    end

    CastPetAction(actionSlot)
    return true
end

Cat2.RegisterCard(card)
