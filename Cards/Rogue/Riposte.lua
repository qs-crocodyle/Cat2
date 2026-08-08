-- 还击 技能卡片。
local card = {
    id = "rogue_riposte",
    name = "还击",
    description = "可用时，尝试施放还击",
    details = "可用时，尝试施放还击。需要存在有效目标。会检查当前资源。",
    sort = 40,
    category = "class",
    classes = {
        ROGUE = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_Challange",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if player.power>=10 then
        CastSpellByName("还击")
        -- 这里没侦测招架，直接返回，避免卡技能
    end

    return false
end

Cat2.RegisterCard(card)
