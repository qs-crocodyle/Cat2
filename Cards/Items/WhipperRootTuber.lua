-- 鞭根块茎卡片。
local card = {
    id = "item_whipper_root_tuber",
    name = "鞭根块茎",
    description = "血量低于|cff6bc7e0{triggerPercent}%|r时使用鞭根块茎",
    details = "战斗中血量低于卡片设定值时，使用鞭根块茎。未单独设置时使用默认值30%。",
    sort = 40,
    category = "item",
    icons = {
        "Interface\\Icons\\INV_Misc_Food_55",
    },
    cooldown = {
        type = "item",
        name = "鞭根块茎",
    },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发血量",
            unit = "%",
            default = 30,
            minimum = 1,
            maximum = 99,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local percent = context:GetStepOption(step, "triggerPercent") or 30
    local player = Cat2.PlayerInformation.temporary

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end

    if player.inCombat and player.percentHealth<percent then
		Cat2.UseItemByName("鞭根块茎")
    end
end

Cat2.RegisterCard(card)
