-- 照明弹（自己）技能卡片。
local card = {
    id = "hunter_flare_self",
    name = "照明弹（自己）",
    description = "以自己为施法位置使用照明弹，需UnitXP202607以上",
    details = "技能冷却完成时，以自己为施法位置使用照明弹，成功执行时会阻断本轮后续卡片。",
    sort = 999,
    category = "class",
    exclusiveGroup = "hunter_flare",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Flare",
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

    if not Cat2.SpellReady("照明弹") then
        return false
    end

    Cat2.Cast("照明弹")
    UnitXP("castAOE", "player")

    return true
end

Cat2.RegisterCard(card)
