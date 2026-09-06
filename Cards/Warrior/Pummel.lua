-- 拳击 技能卡片。
local card = {
    id = "warrior_pummel",
    name = "拳击",
    description = "目标施放|cff6bc7e0{interruptSpellName}|r时使用拳击；技能名为空则打断任意读条",
    details = "目标读条时施放拳击。打断技能名为空时沿用原有机制，打断任意捕获到的敌方读条；填写后仅在敌方施法名与设定内容完全相同时施放。需SuperWoW模组。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 150,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\INV_Gauntlets_04",
    },
    cooldown = {
        type = "spell",
        name = "拳击",
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

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local interruptSpellName = context:GetStepOption(step, "interruptSpellName") or ""

    if not player.targetExists then
        return false
    end

    if Cat2.GetShapeByName("防御姿态") then
        return false
    end

    -- 确认目标正在读条。
    local cast, name = Cat2.TargetCast()
    if not cast then
        return false
    end
    if interruptSpellName ~= "" and name ~= interruptSpellName then
        return false
    end

    if player.power >= 10 and Cat2.SpellReady("拳击") then
        Cat2.Cast("拳击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
