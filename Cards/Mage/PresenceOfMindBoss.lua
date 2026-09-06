-- 气定神闲仅在强敌阶段使用的技能卡片。
local card = {
    id = "mage_presence_of_mind_boss",
    name = "气定神闲 仅强敌时",
    description = "强敌阶段技能冷却后，施放气定神闲",
    details = "强敌阶段技能冷却后，施放气定神闲。需要存在有效目标。仅在技能可用时尝试执行。",
    sort = 111,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_EnchantArmor",
    },
    cooldown = {
        type = "spell",
        name = "气定神闲",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,15)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists or not Cat2.IsBossTarget() then
        return false
    end


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    if Cat2.MageCalmReady() then
        Cat2.Cast("气定神闲")
    end

    return false
end

Cat2.RegisterCard(card)
