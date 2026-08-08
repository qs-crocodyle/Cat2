-- 奉献 技能卡片。
local card = {
    id = "paladin_consecration",
    name = "奉献",
    description = "在近战范围时，施放奉献",
    details = "在近战范围时，施放奉献。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 110,
    category = "class",
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_InnerFire",
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


    -- 近战距离
    if not Cat2.TargetDistance() then
        return false
    end

    if Cat2.SpellReady("奉献") then
        CastSpellByName("奉献")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
