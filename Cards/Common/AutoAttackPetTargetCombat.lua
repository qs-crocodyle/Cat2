-- 覆盖 Cat2/Cards/Common/AutoAttackPetTargetCombat.lua。
-- 仅对已经进入战斗的玩家目标命令宠物攻击，并增加通用安全条件。
local card = {
    id = "common_auto_attack_pet_target_combat",
    name = "宠物自动攻击（已进入战斗目标）",
    description = "目标进入战斗时按最远接敌距离|cff6bc7e0{maximumDistance}码|r让宠物攻击；0为不限；视野检查：|cff6bc7e0{requireLineOfSight}|r",
    details = "宠物和当前敌对目标均有效，且当前目标已经进入战斗时，让宠物攻击术士或猎人当前目标。玩家切换到另一名已进入战斗的目标后会让宠物转火。最远接敌距离默认0，表示不限距离；大于0时才检查距离。视野检查默认关闭。宠物死亡或目标无效时不会执行。执行后不会阻断本轮后续卡片。",
    sort = 11.5,
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

function card.RefreshRuntimeData()
end

local function CanAttackCurrentTarget(context, step)
    local player = Cat2.PlayerInformation.temporary

    if not UnitExists("pet") or UnitIsDeadOrGhost("pet") then
        return false
    end
    if not player.targetExists or not player.targetInCombat
        or not UnitCanAttack("player", "target") or UnitIsDeadOrGhost("target") then
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

    return true
end

function card.Execute(context, step)
    if not CanAttackCurrentTarget(context, step) then
        return false
    end

    PetAttack()
    return false
end


Cat2.RegisterCard(card)
