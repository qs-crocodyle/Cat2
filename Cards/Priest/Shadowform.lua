-- 暗影形态 技能卡片。
local card = {
    id = "priest_shadowform",
    name = "暗影形态",
    description = "保持并施放暗影形态",
    details = "保持并施放暗影形态。成功执行时会阻断本轮后续卡片。",
    sort = 5,
    category = "class",
    classes = {
        PRIEST = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_Shadowform",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(3,17)
end

function card.Execute(context)

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    if not player.buff["暗影形态"] then
        CastSpellByName("暗影形态")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
