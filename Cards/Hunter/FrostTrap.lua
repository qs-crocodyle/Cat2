-- 冰霜陷阱 技能卡片。
local card = {
    id = "hunter_frost_trap",
    name = "冰霜陷阱",
    description = "近战距离时，施放冰霜陷阱，需SuperWoW",
    details = "近战距离时，施放冰霜陷阱，需SuperWoW。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。",
    sort = 100,
    exclusiveGroup = "hunter_trap",
    category = "class",
    classes = {
        HUNTER = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Frost_ChainsOfIce",
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


    -- 8码内
    if Cat2.TargetDistance() then
        if Cat2.SpellReady("冰霜陷阱") then
            CastSpellByName("冰霜陷阱")
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
