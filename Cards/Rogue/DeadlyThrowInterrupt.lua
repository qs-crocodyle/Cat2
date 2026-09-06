-- 致命投掷的打断用途卡片。
-- 当前仅建立独立配置入口；待确认连击点、能量、距离与目标施法判断后，再补充 Execute 逻辑。
local card = {
    id = "rogue_deadly_throw_interrupt",
    name = "致命投掷（打断）",
    description = "目标施放|cff6bc7e0{interruptSpellName}|r时使用致命投掷；技能名为空则打断任意读条",
    details = "目标读条时使用致命投掷。打断技能名为空时沿用原有机制，打断任意捕获到的敌方读条；填写后仅在敌方施法名与设定内容完全相同时施放。需SuperWoW模组。远程栏必须装备投掷武器。需要存在有效目标。会检查目标距离。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 12,
    category = "class",
    classes = {
        ROGUE = 1,
    },
    icons = {
        "Interface\\Icons\\INV_ThrowingKnife_03",
    },
    optionSchema = {
        {
            key = "interruptSpellName",
            type = "string",
            label = "打断技能名",
            shortLabel = "技能",
            default = "",
        },
    },
}

local range = 30

function card.RefreshRuntimeData()
    local fallbackRange = 30 + (Cat2.IsTalentLearned(1,8)*3)
    range = tonumber(Cat2.Match(Cat2.GetSpellTooltip("致命投掷", "等级 1"), "(%d+)码距离"))
    if not range then range = fallbackRange end
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local interruptSpellName = context:GetStepOption(step, "interruptSpellName") or ""

    -- 致命投掷必须由远程栏中的投掷武器支持。
    if not Cat2.IsRangedThrownWeapon() then
        return false
    end

    if not player.targetExists then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and (targetDistance <= 8 or targetDistance > range) then
            return false
        end
    end

    -- 确认目标正在读条
    local cast,name = Cat2.TargetCast()
    if not cast then
        return false
    end
    if interruptSpellName ~= "" and name ~= interruptSpellName then
        return false
    end

    if player.power >= 40 and Cat2.SpellReady("致命投掷") then
        Cat2.Cast("致命投掷")
        return true
    end


    return false
end

Cat2.RegisterCard(card)
