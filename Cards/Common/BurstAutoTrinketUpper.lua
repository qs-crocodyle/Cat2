-- 爆发饰品自动开启（上）：复制“饰品自动开启（上）”，机制暂时保持一致。
local card = {
    id = "common_burst_auto_trinket_upper",
    name = "爆发饰品自动开启（上）",
    description = "上方饰品命中爆发白名单时自动使用",
    details = "上方饰品槽装备爆发饰品白名单中的饰品时自动使用。会检查目标距离。会检查战斗状态。仅在技能可用时尝试执行。",
    sort = 30.5,
    category = "common",
    icons = {
        "Interface\\Icons\\INV_Jewelry_TrinketPVP_01",
        "Interface\\Icons\\Spell_Holy_BlessingOfStamina",
    },
    cooldown = {
        type = "inventory",
        slot = 13,
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

    if not Cat2.IsBurstTrinket(13) then
        return false
    end

    if GetInventoryItemCooldown("player",13)==0 then
        UseInventoryItem(13)
    end

    return false
end

Cat2.RegisterCard(card)
