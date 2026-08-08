-- 熔岩爆裂 技能卡片。
local card = {
    id = "shaman_lava_burst",
    name = "熔岩爆裂",
    description = "无条件施放熔岩爆裂，适合作为填充",
    details = "无条件施放熔岩爆裂，适合作为填充。需要存在有效目标。",
    sort = 25,
    category = "class",
    classes = {
        SHAMAN = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_MeteorStorm",
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
        if range>36 then
            return false
        end
    end

    CastSpellByName("熔岩爆裂")

end

Cat2.RegisterCard(card)
