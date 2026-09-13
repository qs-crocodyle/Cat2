-- 在当前目标位置施放烈焰风暴的技能卡片。
local card = {
    id = "mage_flamestrike_target",
    name = "烈焰风暴（目标）",
    description = "以目标为施法位置使用烈焰风暴，需UnitXP202607以上",
    details = "存在有效目标时，施放烈焰风暴并将范围指示器落在当前目标位置，成功执行时会阻断本轮后续卡片。",
    sort = 55.2,
    category = "class",
    exclusiveGroup = "mage_flamestrike",
    classes = {
        MAGE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_SelfDestruct",
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

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    Cat2.Cast(Cat2.GetAlternatingFlamestrikeName(context))
    UnitXP("castAOE", "target")

    return true
end

Cat2.RegisterCard(card)
