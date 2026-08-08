-- 撕裂 技能卡片。
local card = {
    id = "warrior_rend",
    name = "撕裂",
    description = "对目标施放并保持撕裂",
    details = "对目标施放并保持撕裂。需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 30,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Gouge",
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

    if Cat2.SetShape("狂暴姿态") then
        return false
    end


    if player.power>=10 and not Cat2.WarriorRend() then
        CastSpellByName("撕裂")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
