-- 多重射击（爆炸弹药）技能卡片。
local card = {
    id = "hunter_multi_shot_explosive_ammo",
    name = "多重射击（爆炸弹药）",
    description = "触发爆炸弹药时，施放多重射击",
    details = "触发爆炸弹药时，施放多重射击。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 55.6,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_UpgradeMoonGlaive",
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


    if player.buff["爆炸弹药"] and Cat2.SpellReady("多重射击") then
        CastSpellByName("多重射击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
