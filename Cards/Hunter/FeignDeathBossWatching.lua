-- 假死（强敌注视）：强敌当前目标是自己时假死；假死期间阻断后续卡片。
local card = {
    id = "hunter_feign_death_boss_watching",
    name = "假死（强敌注视）",
    description = "战斗中被当前强敌注视时施放假死；假死期间阻断流程",
    details = "战斗中，当前目标被判定为强敌且目标的目标是自己时，技能冷却就绪则施放假死，并结束本轮流程。通过Nampower捕获假死Buff移除事件，从效果结束时补充记录冷却。假死Buff存在时，无论是否脱战或仍有目标，执行到本卡都会阻断后续卡片。没有可配置参数。建议放在流程前部，避免前面的攻击卡打断假死。",
    sort = 110,
    category = "class",
    canStopSequence = true,
    classes = {
        HUNTER = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_FeignDeath",
    },
    cooldown = {
        type = "spell",
        name = "假死",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    -- 必须先检查假死：施放后可能已经脱战、丢失目标或不再被强敌注视。
    if player.buff and player.buff["假死"] then
        return true
    end

    -- 与有限无敌药水（强敌注视）使用相同的战斗、强敌和目标的目标门禁。
    if not player.inCombat or not player.targetExists or not Cat2.IsBossTarget() then
        return false
    end
    if not UnitExists("targettarget") or not UnitIsUnit("targettarget", "player") then
        return false
    end
    if not Cat2.HunterFeignDeathReady() then
        return false
    end

    Cat2.Cast("假死")
    return true
end

Cat2.RegisterCard(card)
