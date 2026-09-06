-- 法术反制 技能卡片。
local card = {
    id = "mage_counterspell",
    name = "法术反制",
    description = "目标施放|cff6bc7e0{interruptSpellName}|r时使用法术反制；技能名为空则打断任意读条",
    details = "目标读条时施放法术反制。打断技能名为空时沿用原有机制，打断任意捕获到的敌方读条；填写后仅在敌方施法名与设定内容完全相同时施放。需SuperWoW模组。需要存在有效目标。仅在技能可用时尝试执行。",
    sort = 50,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_IceShock",
    },
    cooldown = {
        type = "spell",
        name = "法术反制",
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

    -- 确认目标正在读条
    local cast,name = Cat2.TargetCast()
    if not cast then
        return false
    end
    if interruptSpellName ~= "" and name ~= interruptSpellName then
        return false
    end


    if Cat2.SpellReady("法术反制") then
        Cat2.Cast("法术反制")
    end


    return false
end

Cat2.RegisterCard(card)
