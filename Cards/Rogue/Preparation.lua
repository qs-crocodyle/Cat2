-- 伺机待发 技能卡片。
local card = {
    id = "rogue_preparation",
    name = "伺机待发",
    description = "死亡标记进入冷却时，施放伺机待发",
    details = "死亡标记进入冷却时，施放伺机待发。需要存在有效目标。会检查战斗状态。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 125,
    category = "class",
    classes = {
        ROGUE = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_AntiShadow",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(3,15)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end

    if Cat2.SpellReady("伺机待发") and not Cat2.SpellReady("死亡标记") and not player.buff["利用弱点"] then
        CastSpellByName("伺机待发")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
