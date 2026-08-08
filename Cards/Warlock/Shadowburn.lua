-- 暗影灼烧 技能卡片。
local card = {
    id = "warlock_shadowburn",
    name = "暗影灼烧",
    description = "技能冷却后，施放暗影灼烧",
    details = "技能冷却后，施放暗影灼烧。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 50,
    category = "class",
    classes = {
        WARLOCK = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_ScourgeBuild",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(3,7)
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

    -- 灵魂碎片保护
    if Cat2.GetItemByNameID("灵魂碎片") <= 0 then
        return false
    end

    if Cat2.SpellReadyOffset("暗影灼烧") then
        CastSpellByName("暗影灼烧")
        return true
    end

    return false

end

Cat2.RegisterCard(card)