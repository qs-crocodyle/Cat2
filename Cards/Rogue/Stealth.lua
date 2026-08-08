-- 潜行 技能卡片。
local card = {
    id = "rogue_stealth",
    name = "潜行 绞喉/伏击",
    description = "潜行时，起手根据目标流血状态选择",
    details = "潜行时，起手根据目标流血状态选择。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 10,
    category = "class",
    canStopSequence = true,
    classes = {
        ROGUE = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Stealth",
        "Interface\\Icons\\Ability_Rogue_Garrote",
        "Interface\\Icons\\Ability_Rogue_Ambush",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if player.buff["潜行"] then
        Cat2.StopAttack()

        if player.targetBleed then
            CastSpellByName("绞喉")
        else
            CastSpellByName("伏击")
        end

        return true
    end

    return false
end

Cat2.RegisterCard(card)
