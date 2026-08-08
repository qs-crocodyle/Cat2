-- 精灵之火（仅目标战斗）卡片；目标进入战斗后才执行原卡逻辑。
local card = {
    id = "druid_faerie_fire_target_combat",
    name = "精灵之火（仅目标战斗）",
    description = "目标处于战斗中时降低其护甲",
    details = "仅在目标处于战斗中时降低目标护甲。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 141,
    category = "class",
    classes = {
        DRUID = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_FaerieFire",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if not player.targetInCombat then
        return false
    end

    -- 形态保护
    if player.buff["熊形态"] or player.buff["巨熊形态"] or player.buff["猎豹形态"] then
        return false
    end

    if not player.targetBuff["精灵之火"] and not player.targetBuff["精灵之火（野性）"] then
        CastSpellByName("精灵之火")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
