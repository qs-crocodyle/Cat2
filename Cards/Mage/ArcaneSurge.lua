-- 奥术涌动 技能卡片。
local card = {
    id = "mage_arcane_surge",
    name = "奥术涌动",
    description = "条件满足时，施放奥术涌动",
    details = "条件满足时，施放奥术涌动。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 30,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\INV_Enchant_EssenceMysticalLarge",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 被动：忽略溃裂
    local arcaneSurgeIgnoreArcaneFracture = context and context.parameters and context.parameters.arcaneSurgeIgnoreArcaneFracture
    if arcaneSurgeIgnoreArcaneFracture then
        if player.buff["奥术溃裂"] then
            return false
        end
    end

    -- 被动：奥术强化
    local arcaneSurgeIgnoreArcanePower = context and context.parameters and context.parameters.arcaneSurgeIgnoreArcanePower
    if arcaneSurgeIgnoreArcanePower then
        if player.buff["奥术强化"] then
            return false
        end
    end

    if Cat2.GetMageArcaneSurge() and Cat2.SpellReady("奥术涌动") then
        Cat2.CastWithoutNampower("奥术涌动")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
