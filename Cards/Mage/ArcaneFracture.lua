-- 奥术溃裂技能卡片。
local card = {
    id = "mage_arcane_fracture",
    name = "奥术溃裂",
    description = "冷却后，施放奥术溃裂",
    details = "冷却后，施放奥术溃裂。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 20,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Arcane_Blast",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,9)
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

    if Cat2.SpellReadyOffset("奥术溃裂",1.5) then
        Cat2.CastWithoutNampower("奥术溃裂")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
