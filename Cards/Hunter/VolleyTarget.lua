-- 乱射（目标）技能卡片。
local card = {
    id = "hunter_volley_target",
    name = "乱射（目标）",
    description = "以目标为施法位置使用乱射，需UnitXP202607以上",
    details = "技能冷却完成且存在有效目标时，以目标为施法位置使用乱射，成功执行时会阻断本轮后续卡片。",
    sort = 57.1,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Marksmanship",
    },
    cooldown = {
        type = "spell",
        name = "乱射",
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

    if not Cat2.SpellReady("乱射") then
        return false
    end

    Cat2.Cast("乱射")
    UnitXP("castAOE", "target")

    return true
end

Cat2.RegisterCard(card)
