-- 吸血鬼的拥抱 技能卡片。
local card = {
    id = "priest_vampiric_embrace",
    name = "吸血鬼的拥抱",
    description = "对目标保持并施放吸血鬼的拥抱",
    details = "对目标保持并施放吸血鬼的拥抱。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 70,
    category = "class",
    classes = {
        PRIEST = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_UnsummonBuilding",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(3,14)
end

function card.Execute(context)

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end

    if not Cat2.GetVampiricDot() then
        CastSpellByName("吸血鬼的拥抱")
        return true
    end

    return false

end

Cat2.RegisterCard(card)