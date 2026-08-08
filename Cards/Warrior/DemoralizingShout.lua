-- 挫志怒吼 技能卡片。
local card = {
    id = "warrior_demoralizing_shout",
    name = "挫志怒吼",
    description = "目标没有挫志时触发",
    details = "目标没有挫志时触发。需要存在有效目标。会检查目标距离。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 30,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_WarCry",
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

    -- 挫志怒吼影响周围敌人，只在目标进入 7 码范围时尝试。
    if not Cat2.TargetDistance("target", 7) then
        return false
    end


    if player.power >= 10 then
        if not player.targetBuff["挫志咆哮"] and not player.targetBuff["挫志怒吼"] then
            CastSpellByName("挫志怒吼")
            return true
        end
    end

    return false
end

Cat2.RegisterCard(card)
