-- 摔绊（始终施放）技能卡片。
local card = {
    id = "hunter_wing_clip_always",
    name = "摔绊（始终施放）",
    description = "目标在8码内且冷却好时，直接施放摔绊",
    details = "目标位于8码近战范围内且技能冷却完成时直接施放摔绊，不检查目标身上是否已有摔绊效果。需要存在有效目标。会检查目标距离。成功执行时会阻断本轮后续卡片。",
    sort = 30.1,
    category = "class",
    classes = {
        HUNTER = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_Trip",
    },
    cooldown = {
        type = "spell",
        name = "摔绊",
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

    -- 与猎人其他近战技能保持一致，目标必须位于8码范围内。
    if not Cat2.TargetDistance("target", 8) then
        return false
    end

    -- 不检查目标现有的摔绊效果；技能可用时直接施放。
    if Cat2.SpellReady("摔绊") then
        Cat2.Cast("摔绊")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
