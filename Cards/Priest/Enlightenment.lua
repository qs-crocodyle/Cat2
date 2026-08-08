-- 启发技能卡片。
local card = {
    id = "priest_enlightenment",
    name = "启发（自己）",
    description = "对自己保持并施放启发",
    details = "对自己保持并施放启发。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 120,
    category = "class",
    classes = {
        PRIEST = 1,
    },
    icons = {
        "Interface\\Icons\\btnholyscriptures",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,15)
end

function card.Execute(context)

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    if not player.buff["启发"] and Cat2.SpellReady("启发") then
        Cat2.CastSpellWithoutTarget("启发", "player")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
