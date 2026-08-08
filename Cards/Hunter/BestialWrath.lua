-- 狂野怒火 技能卡片。
local card = {
    id = "hunter_bestial_wrath",
    name = "狂野怒火",
    description = "技能冷却后，施放狂野怒火",
    details = "技能冷却后，施放狂野怒火。需要存在有效目标。会检查战斗状态。仅在技能可用时尝试执行。",
    sort = 2,
    category = "class",
    classes = {
        HUNTER = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Druid_FerociousBite",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,14)
end

function card.Execute(context)

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if not UnitExists("pet") then
        return false
    end

    if Cat2.SpellReady("狂野怒火") and player.inCombat then
        CastSpellByName("狂野怒火")
    end

    return false
end

Cat2.RegisterCard(card)
