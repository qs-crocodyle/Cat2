-- 自动使用角色装备栏下方饰品槽。
local card = {
    id = "common_auto_trinket_lower",
    name = "饰品自动开启（下）",
    description = "使用下方饰品槽中的饰品",
    details = "使用下方饰品槽中的饰品。会检查目标距离。会检查战斗状态。仅在技能可用时尝试执行。",
    sort = 40,
    category = "common",
    icons = {
        "Interface\\Icons\\INV_Jewelry_TrinketPVP_02",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end

    -- 近战距离 被动卡
    local melee = context and context.parameters and context.parameters.trinketsOnlyMelee
    if melee then
        if not Cat2.TargetDistance() then
            return false
        end
    end

    -- 强敌 被动卡
    local boss = context and context.parameters and context.parameters.trinketsOnlyBoss
    if boss then
        if not Cat2.IsBossTarget() then
            return false
        end
    end

    if GetInventoryItemCooldown("player",14)==0 then
        UseInventoryItem(14)
    end

    return false
end

Cat2.RegisterCard(card)
