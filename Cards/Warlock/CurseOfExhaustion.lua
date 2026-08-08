-- 疲劳诅咒 技能卡片。
local card = {
    id = "warlock_curse_of_exhaustion",
    name = "疲劳诅咒",
    description = "保持并施放疲劳诅咒",
    details = "保持并施放疲劳诅咒。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 70,
    exclusiveGroup = "warlock_major_curse",
    category = "class",
    classes = {
        WARLOCK = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_GrimWard",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,9)
end

function card.Execute(context)

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    local onlyBoss = context and context.parameters and context.parameters.warlockMajorCurseOnlyBoss
    if onlyBoss and not Cat2.IsBossTarget() then
        return false
    end

    if not player.targetBuff["疲劳诅咒"] then
        CastSpellByName("疲劳诅咒")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
