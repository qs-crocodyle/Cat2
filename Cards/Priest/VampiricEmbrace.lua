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
    cooldown = {
        type = "spell",
        name = "吸血鬼的拥抱",
    },
}

local allowUse = 0
local distance = 30

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(3,14)
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("吸血鬼的拥抱", "等级 1"), "(%d+)码距离"))
    if not distance then distance = 30 end
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

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    if not Cat2.GetVampiricDot() and Cat2.SpellReady("吸血鬼的拥抱") then
        Cat2.Cast("吸血鬼的拥抱")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
