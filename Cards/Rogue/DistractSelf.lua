-- 扰乱（自己）技能卡片。
local card = {
    id = "rogue_distract_self",
    name = "扰乱（自己）",
    description = "以自己为施法位置使用扰乱，需UnitXP202607以上",
    details = "技能冷却完成时，以自己为施法位置使用扰乱，成功执行时会阻断本轮后续卡片。",
    sort = 999,
    category = "class",
    exclusiveGroup = "rogue_distract",
    classes = {
        ROGUE = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_Distract",
    },
    cooldown = {
        type = "spell",
        name = "扰乱",
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

    if not Cat2.SpellReady("扰乱") then
        return false
    end

    Cat2.Cast("扰乱")
    UnitXP("castAOE", "player")

    return true
end

Cat2.RegisterCard(card)
