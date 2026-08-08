-- 鞭根块茎卡片。
local card = {
    id = "item_whipper_root_tuber",
    name = "鞭根块茎",
    description = "血量<30% 使用鞭根块茎",
    details = "血量<30% 使用鞭根块茎。会检查战斗状态。",
    sort = 40,
    category = "item",
    icons = {
        "Interface\\Icons\\INV_Misc_Food_55",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local percent = 30
    local player = Cat2.PlayerInformation.temporary

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end

    local p = context and context.parameters and context.parameters.recoveryPercent
    if p then
        percent = p
    end


    if player.inCombat and player.percentHealth<percent then
		Cat2.UseItemByName("鞭根块茎")
    end
end

Cat2.RegisterCard(card)
