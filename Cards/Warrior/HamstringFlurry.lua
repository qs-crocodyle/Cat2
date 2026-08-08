-- 断筋（触发乱舞）技能卡片；执行逻辑与原断筋卡保持一致。
local card = {
    id = "warrior_hamstring_flurry",
    name = "断筋（触发乱舞）",
    description = "施放断筋以触发乱舞",
    details = "施放断筋以触发乱舞。需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 140,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_ShockWave",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    -- 防御姿态下不执行。
    if Cat2.SetShape("防御姿态") then
        return false
    end

    if player.power>=10 and not player.buff["乱舞"] then
        CastSpellByName("断筋")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
