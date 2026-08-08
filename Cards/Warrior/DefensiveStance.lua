-- 防御姿态 技能卡片。
local card = {
    id = "warrior_defensive_stance",
    name = "防御姿态",
    description = "切换并保持防御姿态",
    details = "切换并保持防御姿态。成功执行时会阻断本轮后续卡片。",
    sort = 10,
    category = "class",
    classes = {
        WARRIOR = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_DefensiveStance",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    if not Cat2.SetShape("防御姿态") then
        CastSpellByName("防御姿态")
        return true
    end
    return false
end

Cat2.RegisterCard(card)
