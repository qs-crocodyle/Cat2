-- 大地震击（打断）技能卡片。
--
-- 此卡片专门处理敌方读条，与普通“大地震击”分开配置，
-- 因此不加入 shaman_shock 震击互斥小组。
local card = {
    id = "shaman_earth_shock_interrupt",
    name = "大地震击（打断）",
    description = "目标读条时，施放大地震击打断目标施法",
    details = "目标读条时，施放大地震击打断目标施法。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 51,
    category = "class",
    classes = {
        SHAMAN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_EarthShock",
    },
}

-- 初始化入口：预留给后续需要的缓存或事件注册。
function card.RefreshRuntimeData()
end

-- 仅在目标读条时施放，用于打断而非普通输出循环。
function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if Cat2.UnitXP then
        local range = UnitXP("distanceBetween", "player", "target")
        if range > 20 then
            return false
        end
    end

    -- 确认目标正在读条
    local cast,name = Cat2.TargetCast()
    if not cast then
        return false
    end

    if Cat2.SpellReadyOffset("大地震击", 1.5) then
        CastSpellByName("大地震击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
