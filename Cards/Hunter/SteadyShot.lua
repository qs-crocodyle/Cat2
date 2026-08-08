-- 稳固射击技能卡片。
local card = {
    id = "hunter_steady_shot",
    name = "稳固射击",
    description = "施放稳固射击，并防止其占用自动射击",
    details = "施放稳固射击，并防止其占用自动射击。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 55,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Hunter_SteadyShot",
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


    if player.buff["急速射击"] then
        if Cat2.GetHunterShotLeft()>1.0 then
            Cat2.CastWithoutNampower("稳固射击")
            return true
        end
    else
        if Cat2.GetHunterShotLeft()>1.5 then
            Cat2.CastWithoutNampower("稳固射击")
            return true
        end
    end

    return false
end

Cat2.RegisterCard(card)
