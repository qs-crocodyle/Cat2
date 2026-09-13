-- 致密炸弹（自己）消耗品卡片。
local card = {
    id = "item_dense_dynamite_self",
    name = "致密炸弹（自己）",
    description = "以自己为投掷位置使用致密炸弹，需UnitXP202607以上",
    details = "物品冷却完成时，以自己为投掷位置使用致密炸弹，成功执行时会阻断本轮后续卡片。",
    sort = 999,
    category = "item",
    exclusiveGroup = "dense_dynamite",
    canStopSequence = true,
    icons = {
        "Interface\\Icons\\INV_Misc_Bomb_06",
    },
    cooldown = {
        type = "item",
        name = "致密炸弹",
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

    if not Cat2.GetItemByNameCD("致密炸弹") then
        return false
    end

    if Cat2.UseItemByName("致密炸弹") then
        UnitXP("castAOE", "player")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
