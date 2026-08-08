-- 献祭 技能卡片。
local card = {
    id = "warlock_immolate",
    name = "献祭",
    description = "对目标保持并施放献祭",
    details = "对目标保持并施放献祭。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 20,
    category = "class",
    classes = {
        WARLOCK = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Immolation",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if not Cat2.GetImmolateDot("target", 1.5) and (GetTime()-Cat2.GetImmolateTimer())>0 then
        Cat2.CastWithoutNampower("献祭")
        return true
    end

    return false

end

Cat2.RegisterCard(card)