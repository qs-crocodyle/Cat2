-- 驱邪术 技能卡片。
local card = {
    id = "paladin_exorcism",
    name = "驱邪术",
    description = "当目标是亡灵时，施放驱邪术",
    details = "当目标是亡灵时，施放驱邪术。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 130,
    category = "class",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_Excorcism_02",
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


    -- 目标类型
	if player.targetCreatureType=="亡灵" or player.targetCreatureType=="恶魔" then
        if Cat2.SpellReady("驱邪术") and Cat2.TargetDistance("target",30) then
            CastSpellByName("驱邪术")
            return true
        end
    end


    return false
end

Cat2.RegisterCard(card)
