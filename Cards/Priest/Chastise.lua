-- 责罚技能卡片。
local card = {
    id = "priest_chastise",
    name = "责罚（自己）",
    description = "对自己保持并施放责罚",
    details = "对自己保持并施放责罚。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 130,
    category = "class",
    classes = {
        PRIEST = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_UnyieldingFaith",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,18)
end

function card.Execute(context)

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    if player.percentHealth>80.0 and Cat2.PlayerInformation.basic.level>35 and Cat2.SpellReady("责罚") then
        Cat2.CastSpellWithoutTarget("责罚", "player")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
