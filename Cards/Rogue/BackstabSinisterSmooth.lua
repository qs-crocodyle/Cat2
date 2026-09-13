-- 背刺 技能卡片。
local card = {
    id = "rogue_backstab_sinister_smooth",
    name = "平衡 背刺/邪恶攻击（丝滑版）",
    description = "自动判断，被后背刺/正面邪恶打击，需要UnitXP模组的支持",
    details = "自动判断，自适应主手武器，被后背刺/正面邪恶打击。需要存在有效目标。会检查当前资源。会检查与目标的相对位置。成功执行时会阻断本轮后续卡片。需要UnitXP模组的支持。",
    sort = 31.05,
    exclusiveGroup = "rogue_backstab_sinister",
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

local Dagger = false

function card.RefreshRuntimeData()
    Dagger = Cat2.IsMainHandDagger()
end

-- 复刻撕碎的核心判断；背刺使用固定60能量门槛。
function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 确认主手武器，必须是匕首
    if not Dagger then
        if player.power >= 40 then
            Cat2.Cast("邪恶攻击")
            return true
        end
        return false
    end


    if Cat2.UnitXP then

        if UnitXP("behind", "player", "target") then
            if player.power >= 60 then
                if not player.behind then
                    Cat2.Cast("邪恶攻击")
                else
                    Cat2.Cast("背刺")
                end
                return true
            end
        else
            if player.power >= 40 then
                Cat2.Cast("邪恶攻击")
                return true
            end
        end

    else

        if player.behind then
            if player.power >= 60 then
                Cat2.Cast("背刺")
                return true
            end
        else
            if player.power >= 40 then
                Cat2.Cast("邪恶攻击")
                return true
            end
        end

    end

    return false
end

Cat2.RegisterCard(card)
