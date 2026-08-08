-- 致命投掷的打断用途卡片。
-- 当前仅建立独立配置入口；待确认连击点、能量、距离与目标施法判断后，再补充 Execute 逻辑。
local card = {
    id = "rogue_deadly_throw_interrupt",
    name = "致命投掷（打断）",
    description = "目标读条时，致命投掷打断目标施法，需SuperWoW模组",
    details = "目标读条时，致命投掷打断目标施法，需SuperWoW模组。需要存在有效目标。会检查目标距离。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 12,
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

    -- 确认目标正在读条
    local cast,name = Cat2.TargetCast()
    if not cast then
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
