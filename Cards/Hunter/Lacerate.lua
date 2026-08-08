-- 割伤 技能卡片。
local card = {
    id = "hunter_lacerate",
    name = "割伤",
    description = "距离适合时，施放割伤",
    details = "距离适合时，施放割伤。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 28,
    category = "class",
    classes = {
        HUNTER = 3,
    },
    icons = {
        "Interface\\Icons\\spell_Lacerate_1C",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(3,17)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    if Cat2.TargetDistance("target", 9) then
        if Cat2.SpellReady("割伤") then
            CastSpellByName("割伤")
            return true
        end
    end

    return false

end

Cat2.RegisterCard(card)
