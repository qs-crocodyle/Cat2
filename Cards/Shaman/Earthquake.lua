-- 地震术 技能卡片。
local card = {
    id = "shaman_earthquake",
    name = "地震术",
    description = "冷却时，施放地震术",
    details = "冷却时，施放地震术。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 27,
    category = "class",
    classes = {
        SHAMAN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_Earthquake",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1, 17)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    -- 未学习元素掌握天赋时不执行。
    if allowUse == 0 then
        return false
    end

    -- 有unitxp模组，用于射程过滤
    if Cat2.UnitXP then
        local range = UnitXP("distanceBetween", "player", "target")
        if range>36 then
            return false
        end
    end

    if Cat2.SpellReadyOffset("地震术",1.5) then
        CastSpellByName("地震术")
        return true
    end

end

Cat2.RegisterCard(card)
