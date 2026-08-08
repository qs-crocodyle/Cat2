-- 唤醒 技能卡片。
local card = {
    id = "mage_evocation",
    name = "唤醒",
    description = "蓝量<30%时，施放唤醒",
    details = "蓝量<30%时，施放唤醒。会检查战斗状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 100,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_Purge",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 未进入战斗
    if not player.inCombat then
        return false
    end

    if Cat2.SpellReady("唤醒") and player.percentMana<30.0 then
        CastSpellByName("唤醒")
        return true
    end

    return false
end

Cat2.RegisterCard(card)