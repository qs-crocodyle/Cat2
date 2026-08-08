-- 魔法黄水晶技能卡片。
local card = {
    id = "mage_conjure_mana_citrine",
    name = "法力黄水晶",
    description = "蓝量<50%时，使用魔法黄水晶",
    details = "蓝量<50%时，使用魔法黄水晶。会检查战斗状态。",
    sort = 150,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\INV_Misc_Gem_Opal_01",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end

    if player.percentMana<50.0 then
        Cat2.UseItemByName("法力黄水晶")
    end

    return false

end

Cat2.RegisterCard(card)
