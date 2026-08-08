-- 精灵之火（野性）（仅目标战斗）卡片；目标进入战斗后才执行原卡逻辑。
local card = {
    id = "druid_faerie_fire_feral_target_combat",
    name = "精灵之火（野性）（仅目标战斗）",
    description = "目标处于战斗中时降低其护甲",
    details = "仅在目标处于战斗中时降低目标护甲。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 141,
    category = "class",
    canStopSequence = true,
    classes = {
        DRUID = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_FaerieFire",
    },
}

function card.RefreshRuntimeData()
end

-- 目标必须已经进入战斗，并且玩家处于可施放野性精灵之火的形态。
function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if not player.targetInCombat then
        return false
    end

    if not player.buff["熊形态"] and not player.buff["巨熊形态"] and not player.buff["猎豹形态"] then
        return false
    end

    if Cat2.SpellReady("精灵之火（野性）") then
        if not player.targetBuff["精灵之火"] and not player.targetBuff["精灵之火（野性）"] then
            CastSpellByName("精灵之火（野性）")
            return true
        end
    end

    return false
end

Cat2.RegisterCard(card)
