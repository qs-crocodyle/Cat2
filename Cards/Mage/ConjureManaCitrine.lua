-- 魔法黄水晶技能卡片。
local card = {
    id = "mage_conjure_mana_citrine",
    name = "法力黄水晶",
    description = "蓝量<|cff6bc7e0{triggerPercent}%|r时，使用魔法黄水晶",
    details = "蓝量低于卡片设定值时，使用魔法黄水晶。会检查战斗状态。",
    sort = 150,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\INV_Misc_Gem_Opal_01",
    },
    cooldown = {
        type = "item",
        name = "法力黄水晶",
    },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发蓝量",
            shortLabel = "蓝",
            unit = "%",
            default = 50,
            minimum = 1,
            maximum = 99,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 50

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end

    if player.percentMana < triggerPercent then
        Cat2.UseItemByName("法力黄水晶")
    end

    return false

end

Cat2.RegisterCard(card)
