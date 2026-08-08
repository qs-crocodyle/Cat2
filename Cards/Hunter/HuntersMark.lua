-- 猎人印记 技能卡片。
local card = {
    id = "hunter_hunters_mark",
    name = "猎人印记",
    description = "对目标施放并保持猎人印记",
    details = "对目标施放并保持猎人印记。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 20,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Hunter_SniperShot",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end


    if not player.targetBuff["猎人印记"] then
        CastSpellByName("猎人印记")
        return true
    end

    return false

end

Cat2.RegisterCard(card)