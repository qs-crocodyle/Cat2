-- 盾击 技能卡片。
local card = {
    id = "warrior_shield_bash",
    name = "盾击",
    description = "目标施放|cff6bc7e0{interruptSpellName}|r时使用盾击；技能名为空则打断任意读条",
    details = "目标读条时施放盾击。打断技能名为空时沿用原有机制，打断任意捕获到的敌方读条；填写后仅在敌方施法名与设定内容完全相同时施放。需SuperWoW模组。需要存在有效目标。会检查当前资源。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 40,
    category = "class",
    classes = {
        WARRIOR = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_ShieldBash",
    },
    cooldown = {
        type = "spell",
        name = "盾击",
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

    if not Cat2.PlayerInformation.temporary.buff["防御姿态"] and not Cat2.PlayerInformation.temporary.buff["武器姿态"] then
        return false
    end

    -- 必须有盾牌
    if not Cat2.IsOffHandShield() then
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

    if player.power >= 10 and Cat2.SpellReady("盾击") then
        Cat2.Cast("盾击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
