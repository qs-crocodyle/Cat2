-- 大地震击（打断）技能卡片。
--
-- 此卡片专门处理敌方读条，与普通“大地震击”分开配置，
-- 因此不加入 shaman_shock 震击互斥小组。
local card = {
    id = "shaman_earth_shock_interrupt",
    name = "大地震击（打断）",
    description = "目标施放|cff6bc7e0{interruptSpellName}|r时使用大地震击；技能名为空则打断任意读条",
    details = "目标读条时施放大地震击。打断技能名为空时沿用原有机制，打断任意捕获到的敌方读条；填写后仅在敌方施法名与设定内容完全相同时施放。需SuperWoW模组。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 51,
    category = "class",
    classes = {
        SHAMAN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_EarthShock",
    },
    cooldown = { type = "spell", name = "大地震击" },
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

local distance = 20

-- 初始化入口：预留给后续需要的缓存或事件注册。
function card.RefreshRuntimeData()
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("大地震击", "等级 1"), "(%d+)码距离"))
    if not distance then distance = 20 end
end

-- 仅在目标读条时施放，用于打断而非普通输出循环。
function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local interruptSpellName = context:GetStepOption(step, "interruptSpellName") or ""

    if not player.targetExists then
        return false
    end

    if Cat2.UnitXP then
        local range = UnitXP("distanceBetween", "player", "target")
        if range > distance then
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

    if Cat2.SpellReadyOffset("大地震击", 1.5) then
        Cat2.Cast("大地震击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
