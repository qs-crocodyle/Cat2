-- 虚弱诅咒 技能卡片。
local card = {
    id = "warlock_curse_of_weakness",
    name = "虚弱诅咒",
    description = "保持并施放虚弱诅咒",
    details = "保持并施放虚弱诅咒。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 40,
    exclusiveGroup = "warlock_major_curse",
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_CurseOfMannoroth",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    local onlyBoss = context and context.parameters and context.parameters.warlockMajorCurseOnlyBoss
    if onlyBoss and not Cat2.IsBossTarget() then
        return false
    end

    if not player.targetBuff["虚弱诅咒"] then
        CastSpellByName("虚弱诅咒")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
