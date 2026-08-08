-- 断筋 技能卡片。
local card = {
    id = "warrior_hamstring",
    name = "断筋",
    description = "对目标保持并施放断筋",
    details = "对目标保持并施放断筋。需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 130,
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

    -- 防御姿态 无效
    if Cat2.SetShape("防御姿态") then
        return false
    end

    if player.power>=10 and not player.targetBuff["断筋"] then
        CastSpellByName("断筋")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
