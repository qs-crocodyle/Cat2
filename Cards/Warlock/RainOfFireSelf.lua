-- 火焰之雨（自己）技能卡片。
local card = {
    id = "warlock_rain_of_fire_self",
    name = "火焰之雨（自己）",
    description = "以自己为施法位置使用火焰之雨，需UnitXP202607以上",
    details = "以自己为施法位置使用火焰之雨，成功执行时会阻断本轮后续卡片。",
    sort = 40.1,
    category = "class",
    exclusiveGroup = "warlock_rain_of_fire",
    classes = {
        WARLOCK = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_RainOfFire",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()

    if Cat2.UnitXP then

        local compileTime = UnitXP("version", "coffTimeDateStamp")
        if compileTime>=1782864000 then
            allowUse = 1
        end

    end

end

function card.Execute(context)

    -- 不存在这个模组
    if allowUse==0 then
        DEFAULT_CHAT_FRAME:AddMessage(Cat2.L("|cffff8000当前UnitXP模组版本不支持！|r"))
        return false
    end

    Cat2.Cast("火焰之雨")
    UnitXP("castAOE", "player")

    return true
end

Cat2.RegisterCard(card)
