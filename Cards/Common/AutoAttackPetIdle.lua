-- 新增至 Cat2/Cards/Common/AutoAttackPetIdle.lua。
-- 宠物空闲时接敌：已有宠物目标或宠物仍处于攻击动作时不转火。
local card = {
    id = "common_auto_attack_pet_idle",
    name = "宠物空闲时接敌",
    description = "宠物空闲时按最远接敌距离|cff6bc7e0{maximumDistance}码|r接敌；0为不限；视野检查：|cff6bc7e0{requireLineOfSight}|r",
    details = "宠物没有目标且没有处于攻击动作时，才命令宠物攻击术士或猎人当前目标。玩家切换目标不会令正在攻击的宠物转火；原宠物目标死亡后，下一次执行可接敌当前目标。最远接敌距离默认36码，设为0表示不限距离；大于0时才检查距离。视野检查默认关闭。宠物死亡或目标无效时不会执行。执行后不会阻断本轮后续卡片。",
    sort = 11.25,
    category = "common",
    exclusiveGroup = "common_pet_attack_policy",
    icons = {
        "Interface\\Icons\\Ability_Rogue_ShadowStrikes",
    },
    optionSchema = {
        {
            key = "maximumDistance",
            type = "number",
            label = "最远接敌距离",
            shortLabel = "距离",
            unit = "码",
            default = 36,
            minimum = 0,
            maximum = 100,
        },
        {
            key = "requireLineOfSight",
            type = "boolean",
            label = "检查目标视野",
            shortLabel = "视野",
            unit = "",
            default = false,
        },
    },
}

local function IsPetAttackActive()
    if type(GetPetActionInfo) ~= "function" then
        return false
    end

    local slotTotal = NUM_PET_ACTION_SLOTS or 10
    local slot = 1
    while slot <= slotTotal do
        local actionName, _, _, isToken, isActive = GetPetActionInfo(slot)
        local isAttackAction = actionName == "PET_ATTACK"
        if actionName and isToken then
            if type(getglobal) == "function" then
                actionName = getglobal(actionName) or actionName
            elseif type(_G) == "table" then
                actionName = _G[actionName] or actionName
            end
        end
        if isActive and (isAttackAction or actionName == "攻击" or actionName == "Attack") then
            return true
        end
        slot = slot + 1
    end

    return false
end


function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary

    if not UnitExists("pet") or UnitIsDeadOrGhost("pet") then
        return false
    end

    if UnitExists("pettarget") or IsPetAttackActive() then
        return false
    end

    if not player.targetExists or not UnitCanAttack("player", "target")
        or UnitIsDeadOrGhost("target") then
        return false
    end

    local maximumDistance = context:GetStepOption(step, "maximumDistance") or 36

    local requireLineOfSight = context:GetStepOption(step, "requireLineOfSight")
    if requireLineOfSight == nil then
        requireLineOfSight = false
    end

    if maximumDistance > 0 or requireLineOfSight then
        if not Cat2.UnitXP or type(UnitXP) ~= "function" then
            return false
        end
    end
    if maximumDistance > 0 then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if not targetDistance or targetDistance >= maximumDistance then
            return false
        end
    end
    if requireLineOfSight and not UnitXP("inSight", "player", "target") then
        return false
    end

    PetAttack()
    return false
end

Cat2.RegisterCard(card)
