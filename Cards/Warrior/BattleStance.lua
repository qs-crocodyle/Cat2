-- 战斗姿态 技能卡片。
local card = {
    id = "warrior_battle_stance",
    name = "战斗姿态",
    description = "切换并保持战斗姿态",
    details = "切换并保持战斗姿态。成功执行时会阻断本轮后续卡片。",
    sort = 10,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_OffensiveStance",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    if not Cat2.SetShape("战斗姿态") then
        CastSpellByName("战斗姿态")
        return true
    end
    return false
end

Cat2.RegisterCard(card)
