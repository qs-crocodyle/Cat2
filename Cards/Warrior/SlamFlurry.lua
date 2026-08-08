-- 猛击（乱舞）技能卡片；仅在玩家拥有乱舞 Buff 时执行原猛击逻辑。
local card = {
    id = "warrior_slam_flurry",
    name = "猛击（乱舞）",
    description = "乱舞生效时，保有普攻施放猛击",
    details = "仅在乱舞生效时，保有普攻并在普攻剩余时间大于1.5秒时施放猛击。需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 112,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_DecisiveStrike_New",
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

    -- 只有乱舞 Buff 生效时，才继续执行原猛击逻辑。
    if not player.buff["乱舞"] then
        return false
    end

    if player.power>=15 and Cat2.GetMainHandLeft()>1.5 then
        Cat2.CastWithoutNampower("猛击")
        return true
    end

end

Cat2.RegisterCard(card)
