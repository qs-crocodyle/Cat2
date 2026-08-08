-- 炎爆术（二层法术连击）技能卡片；执行机制与原炎爆术一致。
local card = {
    id = "mage_pyroblast_spell_combo_2",
    name = "炎爆术（二层法术连击）",
    description = "当2层法术连击时，施放炎爆术",
    details = "当2层法术连击时，施放炎爆术。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 52,
    category = "class",
    classes = {
        MAGE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Fireball02",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(2,8)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    if GetTime()-Cat2.GetMageCastPyroblastTimer()>0 then

        if Cat2.GetBuffApplications("Interface\\Icons\\Ability_Mage_Firestarter")>=2 then
            Cat2.CastWithoutNampower("炎爆术")
            return true
        end

    end

    return false

end

Cat2.RegisterCard(card)
