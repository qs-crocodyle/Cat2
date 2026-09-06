-- 奥术涌动 技能卡片。
local card = {
    id = "mage_arcane_surge",
    name = "奥术涌动",
    description = "条件满足时，施放奥术涌动",
    details = "条件满足时，施放奥术涌动。需要存在有效目标；目标奥术免疫时不会施放。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 30,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\INV_Enchant_EssenceMysticalLarge",
    },
    cooldown = {
        type = "spell",
        name = "奥术涌动",
    },
}

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("奥术涌动", "等级 1"), "(%d+)码距离"))
    if not distance then distance = 30 end
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 目标奥术免疫时，不再尝试施放奥术伤害技能。
    if Cat2.IsArcaneImmune() then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    if not Cat2.GetMageArcaneSurge() or not Cat2.SpellReady("奥术涌动") then
        return false
    end

    -- 被动：溃裂即将结束
    local arcaneSurgeWhenArcaneFractureEnding = context and context.parameters and context.parameters.arcaneSurgeWhenArcaneFractureEnding
    if arcaneSurgeWhenArcaneFractureEnding then
        if player.buff["奥术溃裂"] then
            -- 奥蛋引导即将结束
            if Cat2.GetChanneled()<1.5 and Cat2.BuffTime("奥术溃裂")<=2.0 and Cat2.SpellReadyOffset("奥术溃裂", 1.5) then
                CastSpellByName("奥术涌动")
                return true
            end
            return false
        end
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

    Cat2.Cast("奥术涌动")
    return true

end

Cat2.RegisterCard(card)
