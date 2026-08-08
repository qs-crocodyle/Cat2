-- 暗言术：痛 技能卡片。
local card = {
    id = "priest_shadow_word_pain",
    name = "暗言术：痛",
    description = "对目标保持并施放暗言术：痛",
    details = "对目标保持并施放暗言术：痛。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 20,
    category = "class",
    classes = {
        PRIEST = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
    },
}


function card.RefreshRuntimeData()

    local PainDuration = 18 + Cat2.IsTalentLearned(3,4)*3
    if Cat2.CheckInventoryItemName(13,"休眠腐化之眼") then PainDuration=PainDuration+3 end
    if Cat2.CheckInventoryItemName(14,"休眠腐化之眼") then PainDuration=PainDuration+3 end

    Cat2.SetPainDuration(PainDuration)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end

    if not Cat2.GetPainDot() then
        CastSpellByName("暗言术：痛")
        return true
    end

    return false

end

Cat2.RegisterCard(card)