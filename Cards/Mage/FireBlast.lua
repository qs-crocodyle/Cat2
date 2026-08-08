-- 火焰冲击 技能卡片。
local card = {
    id = "mage_fire_blast",
    name = "火焰冲击",
    description = "冷却时，施放火焰冲击",
    details = "冷却时，施放火焰冲击。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 20,
    category = "class",
    classes = {
        MAGE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Fireball",
    },
}

local range = 20

function card.RefreshRuntimeData()
    range = 20 + (Cat2.IsTalentLearned(2,3)*3)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    -- 有效距离
    if Cat2.TargetDistance("target",range) then

        if Cat2.SpellReady("火焰冲击") then
            CastSpellByName("火焰冲击")
            return true
        end

    end

    return false

end

Cat2.RegisterCard(card)