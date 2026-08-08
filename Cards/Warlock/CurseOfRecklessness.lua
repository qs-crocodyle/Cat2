-- 鲁莽诅咒 技能卡片。
local card = {
    id = "warlock_curse_of_recklessness",
    name = "鲁莽诅咒",
    description = "保持并施放鲁莽诅咒",
    details = "保持并施放鲁莽诅咒。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 10,
    exclusiveGroup = "warlock_major_curse",
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_UnholyStrength",
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

    if not player.targetBuff["鲁莽诅咒"] then
        CastSpellByName("鲁莽诅咒")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
