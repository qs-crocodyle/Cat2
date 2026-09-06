-- 沉默技能卡片。
local card = {
    id = "priest_silence",
    name = "沉默",
    description = "目标施放|cff6bc7e0{interruptSpellName}|r时使用沉默；技能名为空则打断任意读条",
    details = "目标读条时施放沉默。打断技能名为空时沿用原有机制，打断任意捕获到的敌方读条；填写后仅在敌方施法名与设定内容完全相同时施放。需SuperWoW模组。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 100,
    category = "class",
    classes = {
        PRIEST = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_ImpPhaseShift",
    },
    cooldown = {
        type = "spell",
        name = "沉默",
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

local distance = 30

function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("沉默", "等级 1"), "(%d+)码距离"))
    if not distance then distance = 30 end
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local interruptSpellName = context:GetStepOption(step, "interruptSpellName") or ""

    if not player.targetExists then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
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

    if Cat2.SpellReady("沉默") then
        Cat2.Cast("沉默")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
