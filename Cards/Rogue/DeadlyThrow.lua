-- 致命投掷技能卡片。
local card = {
    id = "rogue_deadly_throw",
    name = "致命投掷",
    description = "冷却时，施放致命投掷",
    details = "冷却时，施放致命投掷。需要存在有效目标。会检查目标距离。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 11,
    category = "class",
    classes = {
        ROGUE = 1,
    },
    icons = {
        "Interface\\Icons\\INV_ThrowingKnife_03",
    },
}

local range = 30

function card.RefreshRuntimeData()
    range = 30 + (Cat2.IsTalentLearned(1,8)*3)
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    -- 这里应该检测下是否有飞刀

    -- 8码内不可用
    if Cat2.TargetDistance("target",8) then
        return false
    end

    -- 30码内不可用
    if Cat2.TargetDistance("target",range) then
        if player.power >= 40 and Cat2.SpellReady("致命投掷") then
            CastSpellByName("致命投掷")
            return true
        end
    end


    return false
end

Cat2.RegisterCard(card)
