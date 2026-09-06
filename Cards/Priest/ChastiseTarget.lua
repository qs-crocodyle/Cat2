-- 责罚目标版技能卡片。
local card = {
    id = "priest_chastise_target",
    name = "责罚",
    description = "对当前目标施放责罚",
    details = "对当前目标施放责罚。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 129,
    category = "class",
    classes = {
        PRIEST = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_UnyieldingFaith",
    },
    cooldown = {
        type = "spell",
        name = "责罚",
    },
}

local allowUse = 0
local distance = 25

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,18)
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("责罚", "等级 1"), "(%d+)码距离"))
    if not distance then distance = 25 end
end

function card.Execute(context)

    -- 不存在这个天赋时，不进入目标施法逻辑。
    if allowUse==0 then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    if Cat2.PlayerInformation.basic.level>35 and Cat2.SpellReady("责罚") then
        Cat2.Cast("责罚")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
