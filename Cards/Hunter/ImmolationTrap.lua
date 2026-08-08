-- 献祭陷阱 技能卡片。
local card = {
    id = "hunter_immolation_trap",
    name = "献祭陷阱",
    description = "近战距离时，施放献祭陷阱，需SuperWoW",
    details = "近战距离时，施放献祭陷阱，需SuperWoW。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。",
    sort = 90,
    exclusiveGroup = "hunter_trap",
    category = "class",
    classes = {
        HUNTER = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_FlameShock",
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
        if Cat2.SpellReady("献祭陷阱") then
            CastSpellByName("献祭陷阱")
            return false
        end
    end

    return false

end

Cat2.RegisterCard(card)
