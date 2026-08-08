-- 闪电箭 技能卡片。
local card = {
    id = "shaman_lightning_bolt",
    name = "闪电箭",
    description = "无条件施放闪电箭，适合作为填充",
    details = "无条件施放闪电箭，适合作为填充。需要存在有效目标。",
    sort = 10,
    category = "class",
    classes = {
        SHAMAN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_Lightning",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    -- 有unitxp模组，用于射程过滤
    if Cat2.UnitXP then
        local range = UnitXP("distanceBetween", "player", "target")
        if range>30 then
            return false
        end
    end

    CastSpellByName("闪电箭")

    return false
end

Cat2.RegisterCard(card)