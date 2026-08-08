-- 狂暴姿态 技能卡片。
local card = {
    id = "warrior_berserker_stance",
    name = "狂暴姿态",
    description = "切换并保持狂暴姿态",
    details = "切换并保持狂暴姿态。成功执行时会阻断本轮后续卡片。",
    sort = 1,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Racial_Avatar",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    if not Cat2.SetShape("狂暴姿态") then
        CastSpellByName("狂暴姿态")
        return true
    end
    return false
end

Cat2.RegisterCard(card)
