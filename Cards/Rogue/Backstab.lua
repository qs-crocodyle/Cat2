-- 背刺 技能卡片。
local card = {
    id = "rogue_backstab",
    name = "背刺（自适应武器）",
    description = "目标背后且60能量时施放背刺",
    details = "手持匕首，目标背后且60能量时施放背刺，若无匕首，则打邪恶打击。需要存在有效目标。会检查当前资源。会检查与目标的相对位置。成功执行时会阻断本轮后续卡片。",
    sort = 30,
    category = "class",
    canStopSequence = true,
    classes = {
        ROGUE = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_BackStab",
        "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
    },
}

function card.RefreshRuntimeData()
end

-- 复刻撕碎的核心判断；背刺使用固定60能量门槛。
function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 确认主手武器，必须是匕首
    if not Cat2.IsMainHandDagger() then

        if player.power >= 40 then
            CastSpellByName("邪恶攻击")
            return true
        end

    else

        if player.behind and player.power >= 60 then
            CastSpellByName("背刺")
            return true
        end

    end

    return false
end

Cat2.RegisterCard(card)
