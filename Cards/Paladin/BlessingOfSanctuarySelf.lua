-- 圣骑士防护系：对自己保持小庇护祝福。
local card = {
    id = "paladin_blessing_of_sanctuary_self",
    name = "小庇护祝福（自己）",
    description = "对自己施放并保持庇护祝福",
    details = "自己没有庇护祝福或强效庇护祝福时，对自己施放庇护祝福。成功执行时会阻断本轮后续卡片。",
    sort = 71,
    category = "class",
    canStopSequence = true,
    classes = {
        PALADIN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_LightningShield",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(2,7)
end

function card.Execute(context)

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    if player.buff["庇护祝福"] or player.buff["强效庇护祝福"] then
        return false
    end

    if Cat2.CastSpellWithoutTarget("庇护祝福", "player") then
        return true
    end

    return false
end

Cat2.RegisterCard(card)
