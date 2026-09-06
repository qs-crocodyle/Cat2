-- 续点燃（灼烧、火焰冲击）技能卡片。
local card = {
    id = "mage_continue_ignite_scorch_fire_blast",
    name = "续点燃（灼烧、火焰冲击）",
    description = "点燃每跳伤害大于|cff6bc7e0{igniteDamageThreshold}|r时尝试续点燃",
    details = "需要同时安装SuperWoW、Nampower和UnitXP。当前目标存在属于玩家的点燃，且当前每跳伤害严格大于设定阈值时：剩余时间不足1秒且火焰冲击冷却完成则施放火焰冲击，否则继续施放灼烧。目标火焰免疫或超出两个技能的施法距离时不会施放。缺少所需模组或伤害未达到阈值时不执行且不阻断；成功执行时会阻断本轮后续卡片。",
    sort = 998,
    category = "class",
    classes = {
        MAGE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Incinerate",
        "Interface\\Icons\\Spell_Fire_SoulBurn",
        "Interface\\Icons\\Spell_Fire_Fireball",
    },
    optionSchema = {
        {
            key = "igniteDamageThreshold",
            type = "number",
            label = "点燃每跳伤害阈值",
            shortLabel = "点燃阈值",
            unit = "伤害",
            default = 300,
            minimum = 0,
            maximum = 100000,
            integer = true,
        },
    },
}

-- 缓存两个技能的实际射程；读取不到提示文本时使用基础射程与天赋加成兜底。
local scorchRange = 30
local fireBlastRange = 20

function card.RefreshRuntimeData()
    local talentBonus = Cat2.IsTalentLearned(2, 3) * 3

    scorchRange = tonumber(Cat2.Match(Cat2.GetSpellTooltip("灼烧", "等级 1"), "(%d+)码距离"))
        or (30 + talentBonus)
    fireBlastRange = tonumber(Cat2.Match(Cat2.GetSpellTooltip("火焰冲击", "等级 1"), "(%d+)码距离"))
        or (20 + talentBonus)
end

local function TargetIsWithinRange(maxRange)
    -- UnitXP 不可用时无法取得精确距离，不额外阻止游戏自身的施法判断。
    if not Cat2.UnitXP then
        return true
    end

    local targetDistance = UnitXP("distanceBetween", "player", "target")
    return not targetDistance or targetDistance <= maxRange
end

function card.Execute(context, step)
    -- 三项扩展分别提供目标GUID、点燃事件与精确距离；缺少任意一项都安全放行后续卡片。
    if not Cat2.SuperWoW or not Cat2.Nampower or not Cat2.UnitXP then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    -- 点燃状态以目标 GUID 为索引；没有有效目标时不进入续点燃逻辑。
    if not player.targetExists or not player.targetGUID then
        return false
    end

    -- IsPlayerIgnite 会把尚未获得反证的 pending 点燃也视为自己的点燃。
    if Cat2.IsFireImmune() or not Cat2.IsPlayerIgnite(player.targetGUID) then
        return false
    end

    -- 只有当前每跳伤害严格高于卡片阈值，才值得继续投入技能维持点燃。
    local igniteDamageThreshold = context:GetStepOption(step, "igniteDamageThreshold") or 0
    local igniteDamage = Cat2.GetMageIgniteDamage(player.targetGUID)
    if igniteDamage <= igniteDamageThreshold then
        return false
    end

    local igniteRemaining = Cat2.GetMageIgniteRemaining(player.targetGUID)
    -- 不足1秒时优先用瞬发火焰冲击抢在点燃结束前续上。
    if igniteRemaining < 1
        and Cat2.SpellReady("火焰冲击")
        and TargetIsWithinRange(fireBlastRange) then
        Cat2.Cast("火焰冲击")
        return true
    end

    -- 点燃仍充裕，或火焰冲击不可用/距离不足时，统一回退到灼烧。
    if not TargetIsWithinRange(scorchRange) then
        return false
    end

    Cat2.Cast("灼烧")
    return true
end

Cat2.RegisterCard(card)
