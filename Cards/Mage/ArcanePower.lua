-- 奥术强化 技能卡片。
local card = {
    id = "mage_arcane_power",
    name = "奥术强化",
    description = "蓝量>50%时，冷却后施放奥术强化",
    details = "蓝量>50%时，冷却后施放奥术强化。会检查战斗状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 120,
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

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    -- 未进入战斗
    if not player.inCombat then
        return false
    end

    if Cat2.SpellReadyOffset("奥术强化",1.5) and player.percentMana>50.0 then
        Cat2.CastWithoutNampower("奥术强化")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
