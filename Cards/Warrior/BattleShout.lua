-- 战斗怒吼 技能卡片。
local card = {
    id = "warrior_battle_shout",
    name = "战斗怒吼",
    description = "保持并施放战斗怒吼",
    details = "保持并施放战斗怒吼。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 20,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_BattleShout",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if player.power>=10 and not player.buff["战斗怒吼"] then
        CastSpellByName("战斗怒吼")
        return true
    end

end

Cat2.RegisterCard(card)