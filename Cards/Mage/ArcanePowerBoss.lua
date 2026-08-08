-- 奥术强化仅在强敌阶段使用的技能卡片。
local card = {
    id = "mage_arcane_power_boss",
    name = "奥术强化 仅强敌时",
    description = "强敌阶段蓝量>50%时，冷却后施放奥术强化",
    details = "强敌阶段蓝量>50%时，冷却后施放奥术强化。需要存在有效目标。会检查战斗状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 121,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_Lightning",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,19)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 未进入战斗或当前目标不是强敌
    if not player.inCombat or not player.targetExists or not Cat2.IsBossTarget() then
        return false
    end


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    if Cat2.SpellReadyOffset("奥术强化",1.5) and player.percentMana>50.0 then
        Cat2.CastWithoutNampower("奥术强化")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
